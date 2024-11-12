# Quick-and-Dirty Nextflow Nix Flake

Nix Flake that provides:

* Nextflow 23.04.2
* NF-Test 0.9.2
* Groovy 3.0.11

> [!CAUTION]
> The Nextflow fat binaries seem to dump Java classes -- amongst other
> things -- into `~/.nextflow`; which doesn't seem very "Nix-y". For
> v23.04.2, I have to physically remove `jackson-core-{2.12.7,2.13.3}.jar`
> to get Nextflow to work correctly :shrug:

Start a development shell with:

```console
$ nix develop
```
