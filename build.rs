use std::path::PathBuf;

use ethers_solc::{Project, ProjectPathsConfig, SolcConfig};
use ethers_contract_abigen::MultiAbigen;
use ethers_solc::artifacts::{Settings};

fn main() {
    let root = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    let paths = ProjectPathsConfig::builder().root(&root).sources(&root.join("contracts")).
        artifacts("out").build().unwrap();
    let settings = Settings { ..Default::default() };
    let solc_config = SolcConfig::builder().settings(settings).build();
    let project = Project::builder().paths(paths).solc_config(solc_config).build().unwrap();

    let output = project.compile().unwrap();

    if output.has_compiler_errors() {
        let compiler_out = output.output();
        let errors = compiler_out.errors;
        for err in errors {
            println!("Compiling file {:?} failed with {:?}", err.source_location.unwrap(), err.message);
        }
        panic!("Contract compile failed");
    }

    let gen = MultiAbigen::from_json_files(root.join("out")).unwrap();
    let bindings = gen.build().unwrap();
    bindings.write_to_module("src/bindings", false).unwrap();
}