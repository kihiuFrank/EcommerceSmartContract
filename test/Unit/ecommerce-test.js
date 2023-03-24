const { assert, expect } = require("chai")
const { network, ethers, deployments } = require("hardhat")
const { developmentChains } = require("../../helper-hardhat-config")

!developmentChains.includes(network.name)
    ? describe.skip
    : describe("Ecommerce Unit Tests", () => {
          let accounts, deployer, ecommerce, player
          const TITLE = "bike"
          const DESCRIPTION = "Electric bike"
          const PRICE = ethers.utils.parseEther("1")

          beforeEach("Runs before every test", async () => {
              accounts = await ethers.getSigners()
              deployer = accounts[0]
              player = accounts[1]
              //deployer = (await getNamedAccounts()).deployer
              await deployments.fixture(["all"])
              ecommerce = await ethers.getContract("Ecommerce", deployer)
          })

          it("deploys succefully", () => {
              assert(ecommerce.address)
          })

          describe("Registering a Product", () => {
              it("checks if price is greater than 0", async () => {
                  const testPrice = ethers.utils.parseEther("0")
                  await expect(
                      ecommerce.registerProduct(TITLE, DESCRIPTION, testPrice)
                  ).to.be.revertedWithCustomError(ecommerce, "Ecommerce__PriceMustBeGreater0")
              })

              it("Registers a product succesfully and emits an event", async () => {
                  expect(await ecommerce.registerProduct(TITLE, DESCRIPTION, PRICE)).to.emit(
                      "Registered"
                  )
              })
          })

          // Needs revisting
          describe("Buying a Product", () => {
              it("checks that buyer pays exact price", async () => {
                  const productId = 1
                  //const testPrice = ethers.utils.parseEther("1")
                  // connect the buyer/player
                  const playerConnectedEcommerce = ecommerce.connect(player)

                  // first register product
                  await ecommerce.registerProduct(TITLE, DESCRIPTION, PRICE)

                  // buy
                  console.log("Now we buy")
                  await expect(
                      playerConnectedEcommerce.buy(productId)
                  ).to.be.revertedWithCustomError(ecommerce, "Ecommerce__PriceNotMet")
              })

              it("checks that seller cannot be the buyer ", async () => {
                  const productId = 1
                  // first register product
                  await ecommerce.registerProduct(TITLE, DESCRIPTION, PRICE)
                  // buy
                  await expect(
                      ecommerce.buy(productId, { value: PRICE })
                  ).to.be.revertedWithCustomError(ecommerce, "Ecommerce__SellerCannotBeBuyer")
              })

              it("checks that product is bought successfully and emits event", async () => {
                  const productId = 1
                  // connect the buyer/player
                  const playerConnectedEcommerce = ecommerce.connect(player)
                  // first register product
                  await ecommerce.registerProduct(TITLE, DESCRIPTION, PRICE)
                  // buy
                  console.log("Now we buy")
                  await expect(playerConnectedEcommerce.buy(productId)).to.emit("Bought")
              })
          })
      })
