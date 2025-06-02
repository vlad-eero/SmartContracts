FROM ghcr.io/foundry-rs/foundry:latest

USER root

# Install necessary packages
RUN apt-get update && \
    apt-get install -y curl sudo && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean

WORKDIR /app

# Initialize a new Foundry project
RUN forge init

# Install OpenZeppelin and forge-std as dependencies
RUN forge install OpenZeppelin/openzeppelin-contracts@v4.9.0 && \
    forge install OpenZeppelin/openzeppelin-contracts-upgradeable@v4.9.0 && \
    forge install foundry-rs/forge-std

# Add remappings for easier imports
RUN echo "@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/\nforge-std/=lib/forge-std/src/" > remappings.txt

# Keep container running
CMD ["bash"]
