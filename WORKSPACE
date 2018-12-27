workspace(name = "rules_coursier")

load("@rules_coursier//rules:coursier.bzl", "install_coursier_repository")

maven_jar(
    name = "rules_coursier_coursier_cache",
    artifact = "io.get-coursier:coursier-cache_2.12:1.1.0-M8",
)

maven_jar(
    name = "rules_coursier_coursier_core",
    artifact = "io.get-coursier:coursier-core_2.12:1.1.0-M8",
)

maven_jar(
    name = "rules_coursier_scala_library",
    artifact = "org.scala-lang:scala-library:2.12.6",
)

maven_jar(
    name = "rules_coursier_scala_xml",
    artifact = "org.scala-lang.modules:scala-xml_2.12:1.1.0",
)

install_coursier_repository(
    name = "coursier",
    url = "https://git.io/vgvpD",
)

load("@rules_coursier//rules:coursier.bzl", "coursier_repository")

coursier_repository(
    name = "jvm_deps",
    coordinates = [
        "io.circe:circe-core_2.12:0.10.1",
        "org.apache.spark:spark-core_2.12:2.4.0",
        "org.typelevel:cats-core_2.12:1.4.0",
    ],
)
