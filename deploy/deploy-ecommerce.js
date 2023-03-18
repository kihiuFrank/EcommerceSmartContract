const { network } = require("hardhat")
const { developmentChains } = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    log("-----------------------------------------------------")
    const args = []
    const ecommerce = deploy("Ecommerce", {
        from: deployer,
        args: args,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })

    // verify contract
    if (!developmentChains.includes(network.name && process.env.ETHERSCAN_API_KEY)) {
        log("Verifying.....")
        await verify(ecommerce.address, args)
    }
    log("-----------------------------------------------------")
}

module.exports.tags = ["all", "ecommerce"]
