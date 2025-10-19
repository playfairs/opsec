# Opsec Debian Package

## This package is a Hosted Debian Package Repository, in order to install this package, you need to run the following commands:

```bash
echo "deb [trusted=yes] https://opsec.playfairs.cc ./" | sudo tee /etc/apt/sources.list.d/opsec-github.list
sudo apt update
sudo apt install opsec
```
Then you can run
```bash
opsec
```

>[!NOTE]
> Nothing about this package is opsec, this package is just a troll package meant to fit into the whole "sudo apt install opsec" joke.