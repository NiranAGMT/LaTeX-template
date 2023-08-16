FROM texlive/texlive:latest

# Copy the entire project into the image.
COPY . /project

# Navigate to the project directory.
WORKDIR /project

# Make the build script executable.
RUN chmod +x .build/build.sh

# Run the project build script.
CMD [".build/build.sh"]