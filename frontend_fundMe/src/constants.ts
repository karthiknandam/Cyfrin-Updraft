export const contractAddress = "HAHA NOT GONNA TELL YOU"; // use the contract address which you have diployed to the sepholia and get back the address

// cunstomize the abi according to your contract i have stuggled a lot with this so be make sure to useCorrect ABI

export const abi = [
  {
    inputs: [{ internalType: "address", name: "provider", type: "address" }],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    inputs: [],
    name: "FundMe_Error",
    type: "error",
  },
  {
    inputs: [],
    name: "MIN_USD",
    outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "fund",
    outputs: [],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [],
    name: "Withdraw",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [{ internalType: "address", name: "Address", type: "address" }],
    name: "getAmoutOfAddress",
    outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [{ internalType: "uint256", name: "Index", type: "uint256" }],
    name: "getUserAddress",
    outputs: [{ internalType: "address", name: "", type: "address" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "getOwner",
    outputs: [{ internalType: "address", name: "", type: "address" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "getVersion",
    outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
    stateMutability: "view",
    type: "function",
  },
  {
    stateMutability: "payable",
    type: "receive",
  },
  {
    stateMutability: "payable",
    type: "fallback",
  },
];
