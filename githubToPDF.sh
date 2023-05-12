#!/bin/bash
set -e

# Check if pdftk is installed
if ! command -v pdftk >/dev/null 2>&1; then
  echo "🚨 pdftk is required but not installed. Installing pdftk..."
  if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install pdftk-java
  else
    echo "Please install pdftk manually."
    exit 1
  fi
fi

# Check if enscript is installed
if ! command -v enscript >/dev/null 2>&1; then
  echo "🚨 enscript is required but not installed. Installing enscript..."
  if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install enscript
  else
    echo "Please install enscript manually."
    exit 1
  fi
fi

# Initialize variables
repo_url=""
skip_dirs=""

# Parse command line arguments
while getopts "r:s:" opt; do
  case $opt in
    r)
      repo_url="$OPTARG"
      ;;
    s)
      skip_dirs="$OPTARG"
      ;;
    *)
      echo "Usage: $0 -r <repository_url> [-s <directories_to_skip>]"
      exit 1
      ;;
  esac
done

# Prepare repository name and temporary directory
repo_name="$(basename "${repo_url%.git}")"
temp_dir="$(mktemp -d)"
pdf_files=()

# Remove temporary directory on exit
trap 'rm -rf "$temp_dir"' EXIT

# Clone repository
echo "📥 Cloning repository: $repo_url"
git clone "$repo_url" "$temp_dir"
cd "$temp_dir"

# Prepare find command to exclude directories
find_cmd="find . -type f"
if [[ -n "$skip_dirs" ]]; then
  for dir in ${skip_dirs//,/ }; do
    find_cmd+=" -not -path \"./${dir}/*\""
  done
fi

# Process each file in the repository
while IFS= read -r -d '' file; do
  file_type=$(file --mime-type -b "$file")
  if [[ "$file_type" == text/* ]]; then
    temp_file="$(mktemp)"
    output_file="${temp_file}.pdf"
    mv "$temp_file" "$output_file"

    pdf_files+=("$output_file")
    echo "🔍 Processing file: $file"
    temp_txt_file="$(mktemp)"
    echo "# File: $file" > "$temp_txt_file"
    cat "$file" >> "$temp_txt_file"
    enscript -E -B -q --margins=50:50:50:50 -f "Courier10" -o - "$temp_txt_file" | ps2pdf - "$output_file"
    rm "$temp_txt_file"

  else
    echo "❌ Skipping unsupported file type: $file"
  fi
done < <(eval "$find_cmd -print0")

# Combine PDF files and move the result to the original directory
echo "📑 Joining PDF files..."
pdftk "${pdf_files[@]}" cat output "${repo_name}.pdf"
mv "${repo_name}.pdf" "${OLDPWD}"

echo "🎉 PDF Creation Completed! Happy Reading 📚"
