use std::io;
use std::io::Write;
mod argparse;
mod partitioner;
#[cfg(test)]
mod tests;
pub use argparse::parse;
#[cfg(test)]
fn exit(code: i32) -> ! {
    panic!("Exit code: {}", code);
}
#[cfg(not(test))]
fn exit(code: i32) -> ! {
    std::process::exit(code)
}
pub struct Config {
    disk: String,
    encrypt: bool,
    home_src: Option<String>,
    root: Option<i32>,
    swap: Option<i32>,
    home: Option<i32>,
    hostname: Option<String>,
    username: Option<String>,
    mountpoint: Option<String>,
    lvm: Option<bool>,
    luks_password: Option<String>,
}
impl Config {
    fn parse_disk_size(size: String) -> i32 {
        let _ = size;
        // Logic will come later
        4
    }
    fn get_password(&mut self) {
        print!(
            "\nWARNING!\n========\nThis will overwrite data on {} irrevocably.\n\nAre you sure? (Type 'yes' in capital letters): ",
            self.disk
        );
        if getline().trim() != "YES" {
            println!("Oparation aborted.");
            exit(0);
        }
        print!("Enter the encryption passphrase: ");
        self.luks_password = Some(getpass());
        print!("Verify passphrase: ");
        if self.luks_password.as_deref().unwrap() != getpass() {
            println!("Passphrases do not match.");
        }
    }
    fn luks_encrypt(&self) {
        let _ = self.luks_password;
    }
    pub fn install(&mut self) {
        self.lvm_conf();
        self.get_password();
        self.luks_encrypt();
        let _ = self.encrypt;
        let _ = self.home_src;
        let _ = self.root;
        let _ = self.swap;
        let _ = self.home;
        let _ = self.hostname;
        let _ = self.username;
        let _ = self.mountpoint;
        let _ = self.lvm;
    }
    fn lvm_conf(&mut self) {
        if self.encrypt && (self.home.is_some() || self.swap.is_some()) {
            self.lvm = Some(true);
        } else {
            self.lvm = Some(false);
        }
    }
}
fn failed_to_read_line() {
    println!("Error reading line from terminal.");
    exit(1);
}
fn getline() -> String {
    io::stdout().flush().unwrap();
    let mut string = String::new();
    match io::stdin().read_line(&mut string) {
        Ok(n) => {
            if n == 0 {
                failed_to_read_line();
            }
        }
        Err(_) => failed_to_read_line(),
    }
    string
}
fn getpass() -> String {
    io::stdout().flush().unwrap();
    rpassword::read_password().unwrap()
}
