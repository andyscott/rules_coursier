def _execute(ctx, *args, quiet = False):
    return ctx.execute(["bash", "-c", """
set -ex
%s""" % "\n".join(args)], quiet = quiet)

def _install_coursier_repository_implementation(ctx):
    _execute(
        ctx,
        "curl -L -o coursier %s" % ctx.attr.url,
        "chmod +x coursier",
    )

    # force bootstrapping
    _execute(ctx, "./coursier --help", quiet = True)

    contents = "\n".join([
        "sh_binary(",
        "    name = \"cli\",",
        "    srcs = [\"coursier\"],",
        ")",
    ]).format()
    ctx.file("BUILD", contents, False)

install_coursier_repository = repository_rule(
    attrs = {
        "url": attr.string(),
    },
    implementation = _install_coursier_repository_implementation,
)

_build_file_template = """
# Generated!

exports_files([
    "jars.json",
    "sources.json",
    "jars.bzl",
    "sources.bzl",
])

"""

def _coursier_repository_implementation(ctx):
    cli = ctx.path(ctx.attr._cli)
    coordinates = " ".join(ctx.attr.coordinates)
    jars = _execute(ctx, "{cli} fetch {coordinates} --json-output-file _jars.json".format(
        cli = cli,
        coordinates = coordinates,
    ))

    sources = _execute(ctx, "{cli} fetch {coordinates} --classifier sources --json-output-file _sources.json".format(
        cli = cli,
        coordinates = coordinates,
    ))

    filter1 = """'
      .dependencies[] |= . + { _file: .file } + (
        .file = ((
          ((.coord | split(":")) | [.[0, 1, -1]] | . as [$org, $mod, $ver] | ($org | split(".")) + [$mod, $ver]) +
          (.file | split("/")[-1] | [.])
        ) | join("/"))
      )'"""

    _execute(
        ctx,
        "jq %s _jars.json > jars.json" % filter1,
        "jq %s _sources.json > sources.json" % filter1,
        "printf 'data = ' > jars.bzl",
        "cat jars.json >> jars.bzl",
        "printf 'data = ' > sources.bzl",
        "cat sources.json >> sources.bzl",
    )

    for json_file in ["jars.json", "sources.json"]:
        _execute(
            ctx,
            "for entry in $(jq -r '.dependencies[] | [._file,.file] | join(\",\")' jars.json); do",
            "  from=${entry%,*}",
            "  to=${entry#*,}",
            "  mkdir -p ${to%/*}",
            "  ln -s $from $to",
            "done",
        )

    contents = _build_file_template.format()
    ctx.file("BUILD", contents, False)

coursier_repository = repository_rule(
    attrs = {
        "coordinates": attr.string_list(),
        "_cli": attr.label(
            cfg = "host",
            default = "@coursier//:coursier",
            executable = True,
        ),
    },
    implementation = _coursier_repository_implementation,
)
