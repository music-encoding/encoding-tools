# MEI Encoding Tools

This project contains a number of tools for working with MEI-encoded files. This includes:

- XSLT Stylesheets for upgrading from one version of MEI to another
- XSLT Stylesheets for converting MEI to other formats (e.g., MusicXML, MARC, MODS, etc.)
- XSLT Stylesheets for converting other formats to MEI (e.g., MusicXML, MARC)

## Usage

If you have Saxon installed on you system and it is available in your command-line you can easily apply the XSLTs to single files or a whole folder of files.

For example, to transform a single file from MEI v5.0 to MEI v5.1 you could call:

```bash
saxon -s:/PATH/TO/INPUT-FILE.mei -xsl:/PATH/TO/encoding-tools/mei50To51/mei50To51.xsl -o:/PATH/TO/OUTPUT-FILE.mei
```

To apply it to a folder the comman would be:

```bash
saxon -s:/PATH/TO/INPUT-DIRECTORY -xsl:/PATH/TO/encoding-tools/mei50To51/mei50To51.xsl -o:/PATH/TO/OUTPUT-DIRECTORY
```

Please be aware that the above comman does not recurse the directory tree and only transforms files located in that directory.

To apply it to all files in directory-structure, and retain the input file-structure in the output directory you can use the `find` command with its `-exec` option to process each file, e.g., transforming the [music-encoding/sample-encodings/MEI_5.0](https://github.com/music-encoding/sample-encodings/tree/main/MEI_5.0) to a new `MEI_5.1` directory:

1. Switch to the `MEI_5.0` directory in your local copy of the sample-encodings:

   ```bash
   cd /PATH/TO/music-encoding/sample-encodings/MEI_5.0
   ```

2. Execute the batch transformation:

   ```bash
   find . -type f -name '*.mei' -exec saxon -s:{} -xsl:../../encoding-tools/mei50To51/mei50To51.xsl -o:../MEI_5.1/{} \;
   ```

### License

Copyright (c) Music Encoding Initiative (MEI) Board.

This repo is released under the [ECL-2.0](LICENSE), and original creations contributed to this repo are accepted under the same license.
