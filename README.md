# GitHub to PDF Converter 📄

This script helps you convert the content of a GitHub repository into a single PDF file. It is useful for feeding codebases to language models, printing code for review, or simply for archival purposes.

## Features

- Download a GitHub repository and convert it into a single PDF file
- Skip specified directories (e.g., `node_modules`) 

## Prerequisites

The script requires `pdftk`, `enscript`, and `ps2pdf` to be installed on your system. The script will attempt to install the required packages automatically for macOS users using Homebrew. If you're on another platform, please install them manually before running the script.

## Usage

1. Clone the repository & enter it:

```bash
git clone https://github.com/kaifirschau/repo-to-pdf.git && cd repo-to-pdf
```

2. Make the script executable:
```bash
chmod +x githubToPDF.sh
```

3. Run the script with the repository URL and the -s flag followed by the directories you want to skip (separated by commas): 
```bash
./githubToPDF.sh -r https://github.com/user/repo -s node_modules,other_directory
```

This command will download the specified repository and create a PDF file with the same name as the repository in your current directory.

## License
This project is open source and available under the MIT License.
