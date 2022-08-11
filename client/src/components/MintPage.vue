<template>
  <div>
    <button v-if="accounts.length === 0" @click="connectToMetamask()">Connect to Metamask</button>
    <button v-else @click="disconnect()">Disconnect</button>
    <div>Account: {{ accounts[0] }}</div>
    <h1>NFT Minting Page</h1>
  </div>
</template>
<script>
import { ethers } from 'ethers'
import { tokenErc721Address, erc721Abi} from "../utils/constants"

export default {
  data() {
    return {
      provider: null,
      accounts: [],
      nftContract: null,
    }
  },
  methods: {
    disconnect() {
      this.provider = null
      this.accounts = []
      this.nftContract = null
    },
    async connectToMetamask() {
      this.provider = new ethers.providers.Web3Provider(window.ethereum)
      this.accounts = await this.provider.send('eth_requestAccounts', [])

      this.createContractInstance()
    },
    createContractInstance() {
      this.nftContract = new ethers.Contract(tokenErc721Address, erc721Abi)
      this.nftContract = this.nftContract.connect(this.provider)
    },
    async mintNft() {
      const signer = this.provider.getSigner()
      const nftContractWithSigner = this.nftContract.connect(signer)

      const transaction = await nftContractWithSigner.mint()
      await transaction.wait()
    }
  }
}
</script>
<style scoped>
button {
  color: white;
  background-color: green;
  padding: 10px 20px;
  margin: 5px;
  border: none;
  border-radius:  5px;
}
button:active {
  background-color: darkgreen;
}
</style>
