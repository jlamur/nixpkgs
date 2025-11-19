# See https://doc.rust-lang.org/cargo/reference/registry-index.html#index-configuration
{ lib, ... }:
{
  name,
  version,
  downloadUrl,
  sha256 ? null,
  ...
}:
with lib.strings;
let
  nameLength = stringLength name;

  # See https://doc.rust-lang.org/cargo/reference/registry-index.html#index-files
  # for more details on how prefixes are computed.
  prefix = if nameLength == 1 then "1" else
    if nameLength == 2 then "2" else
    if nameLength == 3 then "3/${substring 0 1 name}" else
    "${substring 0 2 name}/${substring 2 2 name}";

  templates = {
    "{crate}" = name;
    "{version}" = version;
    "{prefix}" = prefix;
    "{lowerprefix}" = lib.strings.toLower prefix;
    "{sha256-checksum}" =
      if sha256 == null then
        # FIXME: If you encounter this error in the wild, you might want to
        # implement a way to parse the `hash` attr or something like that and
        # use its value if it is a sha256 hash.
        throw "missing sha256 but the cargo template URL ${downloadUrl} requires a sha256 checksum"
      else sha256;
  };
  templateNames = lib.attrNames templates;

  templatedUrl = replaceStrings
    (lib.attrNames templates)
    (lib.attrValues templates)
    downloadUrl;
  nonTemplatedUrl = "${downloadUrl}/${name}/${version}/download";
  finalUrl = if templatedUrl == downloadUrl then nonTemplatedUrl else templatedUrl;
in finalUrl
