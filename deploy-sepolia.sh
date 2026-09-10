#!/usr/bin/env bash
#
#  Deploy the Fashion Passport contract to the SEPOLIA PUBLIC TESTNET.
#
#  HOW TO USE THIS
#  ---------------
#  1. Fill in SEPOLIA_RPC_URL and SEPOLIA_PRIVATE_KEY in your .env
#  2. Make sure that wallet has Sepolia ETH (free from a faucet)
#  3. Run:  ./deploy-sepolia.sh
#
#  This is a REAL public network. The deploy is permanent and anyone can
#  see it on Etherscan. It costs (free) Sepolia ETH, not real money.
#
#  No secrets live in this file — everything comes from .env, which is
#  gitignored and never committed.
#

set -e

# ── Load .env ────────────────────────────────────────────────
if [ ! -f .env ]; then
    echo "ERROR: no .env file found.  Run:  cp .env.example .env"
    exit 1
fi

set -a
source .env
set +a

# ── Sanity checks before spending anything ───────────────────
if [ -z "$SEPOLIA_RPC_URL" ]; then
    echo "ERROR: SEPOLIA_RPC_URL is empty in .env (get one free from alchemy.com)"
    exit 1
fi

if [ -z "$SEPOLIA_PRIVATE_KEY" ]; then
    echo "ERROR: SEPOLIA_PRIVATE_KEY is empty in .env"
    exit 1
fi

MYADDR=$(cast wallet address --private-key "$SEPOLIA_PRIVATE_KEY")
BALANCE=$(cast balance "$MYADDR" --rpc-url "$SEPOLIA_RPC_URL" --ether)

echo ""
echo "=============================================="
echo "  Deploying FashionPassport to SEPOLIA"
echo "=============================================="
echo ""
echo "  Deployer: $MYADDR"
echo "  Balance:  $BALANCE ETH"
echo ""
echo "  This is a PUBLIC network. The contract will be"
echo "  permanent and visible to anyone on Etherscan."
echo ""
read -p "  Continue? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

forge script script/DeployFashionPassport.s.sol:DeployFashionPassport \
    --rpc-url "$SEPOLIA_RPC_URL" \
    --private-key "$SEPOLIA_PRIVATE_KEY" \
    --broadcast

cat <<EOF

==============================================
  Live on Sepolia!
==============================================

Scroll up and copy the "Contract Address: 0x..." line.

--- SEE IT ON ETHERSCAN ------------------------------------------
  Paste your contract address into:

    https://sepolia.etherscan.io/address/<your contract address>

  This is the link you show the judges.

--- MINT A PASSPORT ON THE REAL NETWORK --------------------------
  Takes ~15 seconds to confirm (not instant like Anvil).

source .env
export ADDR=<paste the contract address here>

cast send \$ADDR "createPassport(string,string,string)" "Gucci" "Horsebit Loafers" "ipfs://abc" --rpc-url \$SEPOLIA_RPC_URL --private-key \$SEPOLIA_PRIVATE_KEY

--- CHECK IT (free reads) ----------------------------------------

cast call \$ADDR "ownerOf(uint256)(address)" 1 --rpc-url \$SEPOLIA_RPC_URL
cast call \$ADDR "getPassport(uint256)((string,string,address,uint256,string))" 1 --rpc-url \$SEPOLIA_RPC_URL
cast call \$ADDR "name()(string)" --rpc-url \$SEPOLIA_RPC_URL

--- SEE IT IN METAMASK -------------------------------------------
  MetaMask -> NFTs tab -> Import NFT
  Address: your contract address
  Token ID: 1

EOF
