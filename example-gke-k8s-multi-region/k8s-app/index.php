<?php
function metadata_value($value) {
    $opts = [
        "http" => [
            "method" => "GET",
            "header" => "Metadata-Flavor: Google"
        ]
    ];
    $context = stream_context_create($opts);
    $content = file_get_contents("http://metadata/computeMetadata/v1/$value", false, $context);
    return $content;
}
$zone = basename(metadata_value("instance/zone"));
$region = substr($zone, 0, -2);
printf($region);
?>