#!/bin/bash

# Check if a directory list is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 directory1 directory2 ..."
    exit 1
fi

# Store current directory
ORIGINAL_DIR=$(pwd)

# Function to clean up in case of errors
cleanup() {
    cd "$ORIGINAL_DIR"
    echo "Error occurred. Returning to original directory."
    exit 1
}

# Set error handling
trap cleanup ERR

# Process each directory
for dir in "$@"; do
    if [ ! -d "$dir" ]; then
        echo "Error: $dir is not a directory"
        continue
    fi

    echo "Processing directory: $dir"

    # Change to target directory
    cd "$dir" || cleanup

    # Create python virtual environment
    python3 -m venv venv || cleanup
    # shellcheck disable=SC1091
    source venv/bin/activate || cleanup

    # Create package directory
    mkdir -p package || cleanup

    # Install requirements if requirements.txt exists
    if [ -f "requirements.txt" ]; then
        echo "Installing requirements from requirements.txt"
        pip install -r requirements.txt --target ./package || cleanup
    else
        echo "No requirements.txt found in $dir - skipping dependencies installation"
    fi

    # Copy all .py files to package directory
    if compgen -G "*.py" >/dev/null; then
        cp ./*.py package/ || cleanup
    else
        echo "Warning: No .py files found in $dir"
    fi

    # Create zip file
    cd package || cleanup
    zip -r ../lambda.zip ./* || cleanup
    cd .. || cleanup

    # Cleanup
    rm -rf package
    deactivate
    rm -rf venv

    # Return to original directory
    cd "$ORIGINAL_DIR" || cleanup

    echo "Completed packaging $dir"
    echo "------------------------"
done

echo "All directories processed"
