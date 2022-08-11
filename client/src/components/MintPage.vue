<template>
  <div>
    <button v-if="accounts.length === 0" @click="connectToMetamask()">Connect to Metamask</button>
    <button v-else @click="disconnect()">Disconnect</button>
    <div>Account: {{ accounts[0] }}</div>
    <h1>NFT Minting Page</h1>
    <div v-if="errorMessage.length > 0" class="error-badge"> 
        Error: {{ errorMessage }}
    </div>
    <button @click="mintNft()">Mint</button>
    <div class="nft-container">
      <div class="nft-card" v-for="(nft, index) in nfts" :key="index">
          <h5 class="nft-name">Token # {{ nft.tokenId }}</h5>
          <img :src="nft.image" alt="image" height="150"/>
          <div class="nft-attr">
            <div v-for="(attr, index2) in nft.attributes" :key="index2">
                <strong>{{ attr.trait_type }}</strong> - {{ attr.value }}
            </div>
          </div>
      </div>
    </div>
  </div>
</template>
<script>
import { ethers, utils } from 'ethers'
import { tokenErc721Address, erc721Abi } from "../utils/constants"

export default {
  data() {
    return {
      provider: null,
      accounts: [],
      nftContract: null,
      errorMessage: '',
      nfts: []
    }
  },
  methods: {
    disconnect() {
      this.provider = null
      this.accounts = []
      this.nftContract = null
      this.nfts = []
    },
    async connectToMetamask() {
      this.provider = new ethers.providers.Web3Provider(window.ethereum)
      this.accounts = await this.provider.send('eth_requestAccounts', [])

      this.createContractInstance()
    },
    createContractInstance() {
      this.nftContract = new ethers.Contract(tokenErc721Address, erc721Abi)
      this.nftContract = this.nftContract.connect(this.provider)

      this.getMintedNfts()
    },
    async mintNft() {
      const signer = this.provider.getSigner()
      const nftContractWithSigner = this.nftContract.connect(signer)

      try {
        const transaction = await nftContractWithSigner.mint({
          value: utils.parseEther('1')
        })
        await transaction.wait()
  
        this.errorMessage = ''
        this.getMintedNfts()
        alert('Minted new NFT!')
        
      } catch (error) {
        this.errorMessage = error.data.data.reason || error.data.message
      }
    },
    async getMintedNfts() {
      const _nfts = []
      const eventFilter = this.nftContract.filters.Minted()
      const logs = await this.nftContract.queryFilter(eventFilter)

      for(let i = 0; i < logs.length; i++) {
        const tokenId = logs[i].args.tokenId
        const tokenUri = await this.nftContract.tokenURI(tokenId)
        
        const _response = await fetch(tokenUri)
        const tokenMetadata = await _response.json()

        tokenMetadata.tokenId = tokenId
        _nfts.push(tokenMetadata)
      }

      this.nfts = _nfts
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

.nft-container {
  display: flex;
  flex-direction: row;
  width: 100%;
  justify-content: center;
  flex-wrap: wrap;
}

.nft-card {
  background-color: #ffffff;
    width: auto;
    margin: 8px 8px;
    padding: 10px;
    border-radius: 10px;
    box-shadow: #e1e1e1 1px 1px 8px;
}

.nft-name {
  font-size: 1.3em;
}

.nft-attr {
  text-align: left;
}
</style>
