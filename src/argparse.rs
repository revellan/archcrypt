const ENCRYPT: &str = "--do-not-encrypt";
const USERNAME: &str = "--username";
const ROOT: &str = "--root-part-size";
const HOME: &str = "--home-part-size";
const SWAP: &str = "--swap-part-size";
const HOME_SRC: &str = "--home-dir-source";
const HOSTNAME: &str = "--hostname";
const MOUNTPOINT: &str = "--mountpoint";
const PARSING_ERROR: &str = "Parsing Error.";

use super::Config;
use core::panic;
use revparse::{ArgState, Parser};
fn parsenum<'a>(parser: &mut Parser<'a>, arg: &'a str) -> Option<i32> {
    match parser.get(arg) {
        ArgState::False => None,
        ArgState::Value(val) => Some(Config::parse_disk_size(val)),
        ArgState::True => panic!("{}", PARSING_ERROR),
    }
}
fn parseopt<'a>(parser: &mut Parser<'a>, arg: &'a str) -> Option<String> {
    match parser.get(arg) {
        ArgState::False => None,
        ArgState::Value(val) => Some(val),
        ArgState::True => panic!("{}", PARSING_ERROR),
    }
}
pub fn parse() -> Config {
    let mut parser = Parser::new("archcrypt");
    parser.add_argument(
        ENCRYPT,
        Some("-d"),
        "do not encrypt the installation with luks",
        None,
    );
    parser.add_argument(
        USERNAME,
        Some("-u"),
        "create user with username USERNAME and password 'password'",
        Some("USERNAME"),
    );
    parser.add_argument(
        ROOT,
        Some("-H"),
        "size of the root partition, sizes are explained in the documentation",
        Some("SIZE"),
    );
    parser.add_argument(
        HOME,
        Some("-H"),
        "size of the home partition, sizes are explained in the documentation",
        Some("SIZE"),
    );
    parser.add_argument(
        SWAP,
        Some("-S"),
        "size of the swap partition, sizes are explained in the documentation",
        Some("SIZE"),
    );
    parser.add_argument(
        HOME_SRC,
        Some("-s"),
        "migrate home from DIRECTORY to new home",
        Some("DIRECTORY"),
    );
    parser.add_argument(
        HOSTNAME,
        Some("-n"),
        "hostname for installation",
        Some("HOSTNAME"),
    );
    parser.add_argument(
        MOUNTPOINT,
        Some("-m"),
        "mountpoint to use during the installation process",
        Some("MOUNTPOINT"),
    );
    parser.add_pos_arg("DISK", true);
    parser.pos_arg_help("DISK to install the Operating System on.");
    parser.run();
    let mut pos_args = parser.get_pos_args();
    if pos_args.len() != 1 {
        panic!("{}", PARSING_ERROR);
    }
    let config: Config = Config {
        disk: pos_args.pop().unwrap(),
        encrypt: match parser.get(ENCRYPT) {
            ArgState::False => true,
            ArgState::True => false,
            ArgState::Value(_) => panic!("{}", PARSING_ERROR),
        },
        home_src: parseopt(&mut parser, HOME_SRC),
        root: parsenum(&mut parser, ROOT),
        home: parsenum(&mut parser, HOME),
        swap: parsenum(&mut parser, SWAP),
        hostname: parseopt(&mut parser, HOSTNAME),
        username: parseopt(&mut parser, USERNAME),
        mountpoint: parseopt(&mut parser, MOUNTPOINT),
        lvm: None,
        luks_password: None,
    };
    config
}
