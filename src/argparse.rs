use super::Config;
use revparse::{ArgState, Parser};
pub fn parse() -> Config {
    let mut parser = Parser::new("archcrypt");
    parser.add_argument(
        "--home-dir-source",
        Some("-s"),
        "migrate home from DIRECTORY to new home",
        Some("DIRECTORY"),
    );
    parser.add_argument(
        "--do-not-encrypt",
        Some("-d"),
        "do not encrypt the installation with luks",
        None,
    );
    parser.add_argument(
        "--swap-part-size",
        Some("-S"),
        "size of the swap partition, sizes are explained in the documentation",
        Some("SIZE"),
    );
    parser.add_argument(
        "--home-part-size",
        Some("-H"),
        "size of the home partition, sizes are explained in the documentation",
        Some("SIZE"),
    );
    parser.add_argument(
        "--root-part-size",
        Some("-H"),
        "size of the root partition, sizes are explained in the documentation",
        Some("SIZE"),
    );
    //parser.add_argument("--vg-name", Some("-v"), "name for lvm volume group", Some("VG_NAME"));
    parser.add_argument(
        "--hostname",
        Some("-n"),
        "hostname for installation",
        Some("HOSTNAME"),
    );
    parser.add_argument(
        "--username",
        Some("-u"),
        "create user with username USERNAME and password 'password'",
        Some("USERNAME"),
    );
    parser.add_argument(
        "--mountpoint",
        Some("-m"),
        "mountpoint to use during the installation process",
        Some("MOUNTPOINT"),
    );
    parser.add_pos_arg("DISK");
    parser.pos_arg_help("DISK to install the Operating System on.");
    parser.run();
    match parser.get("--do-not-encrypt") {
        ArgState::False => Config { encrypt: true },
        ArgState::True => Config { encrypt: false },
        ArgState::Value(_) => panic!("Parsing Error."),
    }
}
