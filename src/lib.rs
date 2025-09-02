mod argparse;
mod partitioner;
struct Config {
    encrypt: bool,
}
pub fn install() {
    let conf: Config = argparse::parse();
    if conf.encrypt {
        // do sth
    }
}