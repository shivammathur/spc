# SPC

setup-php-cli (SPC) is a command line utility to run [setup-php](https://github.com/shivammathur/setup-php).

## Install

- Using composer

```bash
composer global require shivammathur/spc
```

- Download from Releases

```bash
# Download
curl -o /tmp/spc -sL https://github.com/shivammathur/spc/releases/latest/download/spc

# Verify
curl -o /tmp/spc.asc -sL https://github.com/shivammathur/spc/releases/latest/download/spc.asc
curl -o /tmp/key.asc -sL https://github.com/shivammathur/spc/releases/latest/download/key.asc
gpg --import /tmp/key.asc
gpg --verify /tmp/spc.asc /tmp/spc

# Install
sudo mv /tmp/spc /usr/local/bin/spc
sudo chmod a+x /usr/local/bin/spc
```

## Options

```bash
-p "[PHP Version]", --php-version "[PHP Version]"    Specify PHP version (Required if PHP is not installed)
-e "[Extensions]", --extensions "[Extensions]"       Specify extensions
-i "[INI Values]", --ini-values "[INI Values]"       Specify ini values
-c "[Coverage]", --coverage "[Coverage]"             Specify Coverage driver
-t "[Tools]", --tools "[Tools]"                      Specify tools
-f "[Fail Fast]", --fail-fast "[Fail Fast]"          Specify fail-fast flag
-z "[PHP TS/NTS]", --phpts "[PHPTS/NTS]"             Specify phpts flag
-u "[Update]", --update "[Update]"                   Specify update flag
-r "[TAG]", --release "[TAG]"                        Specify release
-v, --verbose                                        Specify verbose mode
-V, --version                                        Show version of script
-h, --help                                           Show help
```

## Examples

- Install or switch to a particular PHP version. For example to install `PHP 7.4`.

```bash
spc -p "7.4"
```

- Install PHP extension, say `intl` and `xml` on `PHP 7.4`.

```bash
spc -e "intl, xml"
```

- Add any configuration to your php.ini, say set timezone to `UTC`.

```bash
spc -i "date.timezone=UTC"
```

- Set a coverage driver, say `PCOV`.

```bash
spc -c "pcov"
```

- Install a tool supported by `setup-php` globally.

```bash
spc -t "phpunit"
```

- Fail if an extension, or a tool does not install.

```bash
spc -t "random_tool" -f "true"
```

- Update PHP to the latest patch version.

```bash
spc -u "true"
```

- Setup TS/NTS PHP on `Windows`.

```bash
spc -p "7.4" -z "ts"
```

- Use a particular tag/release of `setup-php`, say to use `v1`.

```bash
spc -r "v1"
```

- To run `spc` in the verbose mode, this will use `verbose` branch of `setup-php`.

```bash
spc -v
```

- To check options spc supports in command line.

```bash
spc -h
```

- To upgrade `spc` to latest version.

```bash
spc -U
```

- To check `spc` version.

```bash
spc -V
```