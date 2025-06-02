FROM ghcr.io/foundry-rs/foundry:latest

USER root

# Install necessary packages
RUN apt-get update && \
    apt-get install -y curl sudo && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean

WORKDIR /workspaces/SmartContracts

# Initialize a new Foundry project
RUN forge init

# Install OpenZeppelin and forge-std as dependencies
# RUN forge install OpenZeppelin/openzeppelin-contracts@v5.0.0 && \
#     forge install OpenZeppelin/openzeppelin-contracts-upgradeable@v5.0.0 && \
#     forge install foundry-rs/forge-std@1.7.1


# Keep container running
CMD ["bash"]
