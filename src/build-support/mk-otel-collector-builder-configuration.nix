{ lib
, writeTextFile
, runCommand
, go
, remarshal
}:

{ name ? "${args'.pname}-${args'.version}-builder-configuration"
, config ? { }
, goPackage ? go
, ...
}@args':
let
  jsonFile = writeTextFile {
    name = "${name}.json";
    text = builtins.toJSON ({
      dist = {
        name = args'.pname;
        go = "${goPackage}/bin/go";
        output_path = "output";
      };
    } // args'.config);
  };
in
runCommand "${name}.yaml"
{
  nativeBuildInputs = [ remarshal ];
} ''
  ${remarshal}/bin/remarshal ${jsonFile} --of yaml > $out
''
