const { assert, expect } = require("chai")
const { network, ethers, deployments } = require("hardhat")
const { developmentChains } = require("../../helper-hardhat-config")

!developmentChains.includes(network.name)
    ? describe.skip
    : describe("Ecommerce Unit Tests", () => {
          let accounts, deployer, ecommerce
          beforeEach("Runs before every test", async () => {
              //accounts = await ethers.getSigners
              //deployer = accounts[0]
              deployer = (await getNamedAccounts()).deployer
              await deployments.fixture(["all"])
              ecommerce = await ethers.getContract("Ecommerce", deployer)
          })

          it("deploys succefully", () => {
              assert(ecommerce.address)
          })
      })
