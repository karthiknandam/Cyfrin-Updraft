import { ChangeEvent, useState, memo } from "react";
import { MdAccountBalanceWallet } from "react-icons/md";
import { ethers } from "ethers";
import { abi, contractAddress } from "./constants.js";
import { MetaMaskInpageProvider } from "@metamask/providers";
import "./index.css";

declare global {
  interface Window {
    ethereum?: MetaMaskInpageProvider;
  }
}

interface Withdraw {
  setBalance: (value: number) => void;
}

interface Connection {
  connect: boolean;
  setConnection: (value: boolean) => void;
}

interface InputSection {
  inputValue: string;
  setInputValue: (value: string) => void;
  setBalance: (value: number) => void;
}

interface TotalBalance {
  balance: number;
}

function App() {
  const inital: number = 0 | Number(localStorage.getItem("balance"));
  const [connect, setConnection] = useState(false);
  const [inputValue, setInputValue] = useState("");

  const [balance, setBalance] = useState(inital);

  return (
    <div className="bg-blue-100 min-h-screen flex flex-col">
      {connect && (
        <div className="flex justify-between pt-4 px-4">
          <TotalBalance balance={balance} />
          <WithdrawFunds setBalance={setBalance} />
        </div>
      )}
      <div className="flex flex-1 justify-center items-center">
        <ButtonConnection connect={connect} setConnection={setConnection} />
      </div>
      {connect && (
        <div className="flex justify-center items-center pb-8">
          <InputFundMeSection
            inputValue={inputValue}
            setInputValue={setInputValue}
            setBalance={setBalance}
          />
        </div>
      )}
    </div>
  );
}

const ButtonConnection = memo(({ connect, setConnection }: Connection) => {
  const handlerOnClickConnect = async () => {
    if (!window.ethereum) {
      console.error("MetaMask or Web3 provider not found.");
      setConnection(false);
      return;
    }
    try {
      await window.ethereum.request({ method: "eth_requestAccounts" });
      const accounts = (await window.ethereum.request({
        method: "eth_accounts",
      })) as string[];
      setConnection(!!accounts.length);
      console.log("Connected accounts:", accounts);
    } catch (error) {
      console.error("Error connecting to wallet:", error);
      setConnection(false);
    }
  };
  return (
    <button
      className="rounded-sm bg-blue-500 pt-1 pb-1 pr-2 pl-2 text-white focus:outline-none focus:ring-3 focus:ring-blue-300 flex items-center gap-1"
      disabled={connect}
      onClick={handlerOnClickConnect}
    >
      <MdAccountBalanceWallet className="top-0 left-0" />
      <span>{connect ? "connected" : "connect"}</span>
    </button>
  );
});

const InputFundMeSection = ({
  inputValue,
  setInputValue,
  setBalance,
}: InputSection) => {
  const handlerOnChange = (e: ChangeEvent<HTMLInputElement>) =>
    setInputValue(e.target.value);

  const handlerSendFundMe = async () => {
    if (!window.ethereum) {
      console.log("Sorry Cannot be funded");
      return;
    }
    console.log(`Funding with ${inputValue}...`);
    try {
      const provider = new ethers.BrowserProvider(window.ethereum);
      await provider.send("eth_requestAccounts", []);
      const signer = await provider.getSigner();
      const contract = new ethers.Contract(contractAddress, abi, signer);
      const transactionResponse = await contract.fund({
        value: ethers.parseEther(inputValue),
      });
      await transactionResponse.wait(1);
      const balance = await provider.getBalance(contractAddress);
      setBalance(+ethers.formatEther(balance));
      localStorage.setItem("balance", ethers.formatEther(balance));
    } catch (error) {
      console.log(error);
    }
    console.log("Processing.....");
  };

  return (
    <div>
      <input
        className="text-gray-400 border border-blue-500 rounded-sm px-2 py-1 focus:outline-none focus:ring-3 focus:ring-blue-400 mr-3"
        type="text"
        value={inputValue}
        placeholder="0.01"
        onChange={handlerOnChange}
        autoFocus
      />
      <button
        className="bg-blue-500 px-2 py-1 rounded-sm text-white focus:outline-none focus:ring-3 focus:ring-blue-300"
        onClick={handlerSendFundMe}
      >
        Send
      </button>
    </div>
  );
};

const WithdrawFunds = ({ setBalance }: Withdraw) => {
  const handlerWithdraw = async () => {
    if (!window.ethereum) {
      alert("Please install MetaMask to withdraw funds.");
      return;
    }
    console.log("Checking contract balance...");
    try {
      const provider = new ethers.BrowserProvider(window.ethereum);
      await provider.send("eth_requestAccounts", []);
      const signer = await provider.getSigner();
      const contract = new ethers.Contract(contractAddress, abi, signer);
      const balance = await provider.getBalance(contractAddress);
      const ethBalance = ethers.formatEther(balance);
      console.log(`Contract Balance: ${ethBalance} ETH`);
      if (parseFloat(ethBalance) <= 0) {
        alert("Contract has insufficient funds to withdraw!");
        return;
      }
      console.log("Processing withdrawal...");
      const transactionResponse = await contract.Withdraw();
      await transactionResponse.wait(1);
      console.log("Withdrawal successful!");
      alert("Withdrawal successful! Check your MetaMask.");
      const balanceVal = await provider.getBalance(contractAddress);
      setBalance(+ethers.formatEther(balanceVal));
      localStorage.setItem("balance", ethers.formatEther(balanceVal));
    } catch (error: any) {
      console.error("Withdrawal failed:", error.message);
      alert("Error: " + error.message);
    }
  };

  return (
    <button
      onClick={handlerWithdraw}
      className="bg-red-600 text-white px-2 py-1 rounded-sm border-none focus:outline-none focus:ring-3 focus:ring-red-400"
    >
      Withdraw
    </button>
  );
};

const TotalBalance = ({ balance }: TotalBalance) => (
  <div className="text-gray-700">{balance}</div>
);

export default App;
