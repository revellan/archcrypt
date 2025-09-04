use archcrypt::Config;
fn main() {
    let mut conf: Config = archcrypt::parse();
    conf.install();
}

