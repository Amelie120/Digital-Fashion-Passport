#!/usr/bin/env bash
#
#  Deploy the Fashion Passport contract to a LOCAL test blockchain (Anvil).
#
#  HOW TO USE THIS
#  ---------------
#  1. First time only:      cp .env.example .env
#  2. Open a terminal:      anvil          (leave it running)
#  3. In a SECOND terminal: ./deploy-local.sh
#  4. Follow the instructions it prints at the end.
#
#  No secrets live in this file. Everything sensitive is read from .env,
#  which is gitignored and never committed.
#

set -e # stop straight away if anything fails

# ── Load .env ────────────────────────────────────────────────
if [ ! -f .env ]; then
    echo ""
    echo "ERROR: no .env file found."
    echo "Create one by copying the template:"
    echo ""
    echo "    cp .env.example .env"
    echo ""
    exit 1
fi

set -a      # mark everything that follows for export
source .env # read the variables in
set +a

# ── Sanity checks ────────────────────────────────────────────
RPC=${ANVIL_RPC_URL:-http://127.0.0.1:8545}

if [ -z "$ANVIL_PRIVATE_KEY" ]; then
    echo "ERROR: ANVIL_PRIVATE_KEY is not set in your .env file."
    exit 1
fi

echo ""
echo "=============================================="
echo "  Deploying FashionPassport to local Anvil"
echo "=============================================="
echo ""
echo "Chain: $RPC"
echo "If this fails with a connection error, Anvil isn't running."
echo "Open another terminal and run:  anvil"
echo ""

forge script script/DeployFashionPassport.s.sol:DeployFashionPassport \
    --rpc-url "$RPC" \
    --private-key "$ANVIL_PRIVATE_KEY" \
    --broadcast

# The commands below are PRINTED, not run, so you can copy them one at a time.
# The \$ are escaped so the text shows literally instead of being substituted.
cat <<EOF

==============================================
  Deployed! Now try talking to your contract
==============================================

Scroll up and copy the line that says "Contract Address: 0x..."
That is where your contract now lives.

--- STEP 1: load your .env into this terminal --------------------
  Do this once per terminal session, then paste the address.

source .env
export ADDR=<paste the contract address here>

--- STEP 2: mint a passport --------------------------------------
  A REAL transaction. Costs gas, mines a block.
  "cast send" = write to the chain.

cast send \$ADDR "createPassport(string,string,string)" "Gucci" "Horsebit Loafers" "ipfs://abc" --rpc-url \$ANVIL_RPC_URL --private-key \$ANVIL_PRIVATE_KEY

--- STEP 3: check it worked --------------------------------------
  These are free. "cast call" = just read, no transaction.

  Who owns passport #1? (should be 0xf39Fd6...)
cast call \$ADDR "ownerOf(uint256)(address)" 1 --rpc-url \$ANVIL_RPC_URL

  What is passport #1? (brand, model, registrar, timestamp, IPFS link)
cast call \$ADDR "getPassport(uint256)((string,string,address,uint256,string))" 1 --rpc-url \$ANVIL_RPC_URL

  What would MetaMask/OpenSea fetch for the image?
cast call \$ADDR "tokenURI(uint256)(string)" 1 --rpc-url \$ANVIL_RPC_URL

  Collection name and ticker (these came free from ERC721)
cast call \$ADDR "name()(string)" --rpc-url \$ANVIL_RPC_URL
cast call \$ADDR "symbol()(string)" --rpc-url \$ANVIL_RPC_URL

EOF
