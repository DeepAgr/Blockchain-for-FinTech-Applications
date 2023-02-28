// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "./PriceConverter.sol";

contract CrossBorderPaymnet {
    using PriceConverter for uint256;
    mapping(address => uint256) userAccount;
    mapping(address => bool) public userExists;

    mapping(address => string) public Bank_Name;
    mapping(address => string) Customer_Name;
    mapping(address => string) Pswd;
    // mapping(string=>uint) public exc;

    // string public bankA = "Bank of India";
    // string bankB = "Bank of Japan";
    // string bankC = "Bank of America";
    // exc[bankA] = 1;

    uint256 public forex_tax;

    function OpenNewAccount(
        string memory BankName,
        string memory CustomerName,
        string memory Password
    ) public payable returns (string memory) {
        require(userExists[msg.sender] == false, "Account Already Created");

        userAccount[msg.sender] = msg.value;
        userExists[msg.sender] = true;

        Bank_Name[msg.sender] = BankName;
        Customer_Name[msg.sender] = CustomerName;
        Pswd[msg.sender] = Password;

        string memory result_note = string(
            abi.encodePacked(
                "Congratulation ",
                CustomerName,
                "! Thanks for choosing ",
                BankName,
                "."
            )
        );
        return (result_note);
    }

    function DepositMoney(string memory Password)
        public
        payable
        returns (string memory)
    {
        require(userExists[msg.sender] == true, "Account is not created");
        require(msg.value > 0, "Value for deposit is Zero");

        if (
            keccak256(abi.encodePacked(Pswd[msg.sender])) ==
            keccak256(abi.encodePacked(Password))
        ) {
            uint256 WEI2USD = msg.value.WEI_to_USD();
            if (
                keccak256(abi.encodePacked(Bank_Name[msg.sender])) ==
                keccak256(abi.encodePacked("Bank of Japan"))
            ) {
                WEI2USD = WEI2USD.USD_to_JPY();
            }
            if (
                keccak256(abi.encodePacked(Bank_Name[msg.sender])) ==
                keccak256(abi.encodePacked("Bank of India"))
            ) {
                WEI2USD = WEI2USD.USD_to_INR();
            }

            userAccount[msg.sender] = userAccount[msg.sender] + WEI2USD;
            return ("Deposited Succesfully..!");
        }

        return ("Wrong Password..!");
    }

    function WithdrawMoney(string memory Password, uint256 Amount)
        public
        payable
        returns (string memory)
    {
        require(
            userAccount[msg.sender] >= Amount,
            "Insufficeint balance in Bank account..!"
        );
        require(userExists[msg.sender] == true, "Account is not created..!");
        require(Amount > 0, "Enter non-zero value for withdrawal...!");

        if (
            keccak256(abi.encodePacked(Pswd[msg.sender])) ==
            keccak256(abi.encodePacked(Password))
        ) {
            userAccount[msg.sender] = userAccount[msg.sender] - Amount;
            if (
                keccak256(abi.encodePacked(Bank_Name[msg.sender])) ==
                keccak256(abi.encodePacked("Bank of Japan"))
            ) {
                Amount = Amount.JPY_to_USD();
            }
            if (
                keccak256(abi.encodePacked(Bank_Name[msg.sender])) ==
                keccak256(abi.encodePacked("Bank of India"))
            ) {
                Amount = Amount.INR_to_USD();
            }
            Amount = Amount.USD_to_WEI();
            payable(msg.sender).transfer(Amount);
            return ("withdrawal Succesful");
        }

        return ("Wrong Password..!");
    }

    function converter(
        string memory SenBank,
        string memory RecBank,
        uint256 amount
    ) internal view returns (uint256) {
        if (
            keccak256(abi.encodePacked(SenBank)) ==
            keccak256(abi.encodePacked("Bank of India"))
        ) {
            if (
                keccak256(abi.encodePacked(RecBank)) ==
                keccak256(abi.encodePacked("Bank of America"))
            ) {
                return (amount.INR_to_USD());
            } else if (
                keccak256(abi.encodePacked(RecBank)) ==
                keccak256(abi.encodePacked("Bank of Japan"))
            ) {
                return (amount.INR_to_JPY());
            }
        } else if (
            keccak256(abi.encodePacked(SenBank)) ==
            keccak256(abi.encodePacked("Bank of Japan"))
        ) {
            if (
                keccak256(abi.encodePacked(RecBank)) ==
                keccak256(abi.encodePacked("Bank of America"))
            ) {
                return (amount.JPY_to_USD());
            } else if (
                keccak256(abi.encodePacked(RecBank)) ==
                keccak256(abi.encodePacked("Bank of India"))
            ) {
                return (amount.JPY_to_INR());
            }
        } else if (
            keccak256(abi.encodePacked(SenBank)) ==
            keccak256(abi.encodePacked("Bank of America"))
        ) {
            if (
                keccak256(abi.encodePacked(RecBank)) ==
                keccak256(abi.encodePacked("Bank of Japan"))
            ) {
                return (amount.USD_to_JPY());
            } else if (
                keccak256(abi.encodePacked(RecBank)) ==
                keccak256(abi.encodePacked("Bank of India"))
            ) {
                return (amount.USD_to_INR());
            }
        }
        return 0;
    }

    function ForiegnExchange(
        string memory Sender_Bank_Name,
        string memory Password,
        string memory Receiver_Bank_Name,
        address payable ReceiverAddress,
        uint256 Transfer_amount
    ) public returns (string memory) {
        if (
            (keccak256(abi.encodePacked(Bank_Name[msg.sender])) ==
                keccak256(abi.encodePacked(Sender_Bank_Name))) &&
            (keccak256(abi.encodePacked(Pswd[msg.sender])) ==
                keccak256(abi.encodePacked(Password)))
        ) {
            require(
                userAccount[msg.sender] > Transfer_amount,
                "Insufficeint balance in Bank account..!"
            );
            require(
                userExists[msg.sender] == true,
                "Account is not created..!"
            );
            require(
                userExists[ReceiverAddress] == true,
                "Receiver's account does not exists in Bank..!"
            );
            require(Transfer_amount > 0, "Enter non-zero value for sending..!");

            uint256 forex_rate = 5;

            uint256 converted_rate = converter(
                Sender_Bank_Name,
                Receiver_Bank_Name,
                Transfer_amount
            );
            uint256 transfer_tax = (Transfer_amount * forex_rate) / 100;
            uint256 converted_tax = converter(
                Sender_Bank_Name,
                Receiver_Bank_Name,
                transfer_tax
            );

            forex_tax = forex_tax + converted_tax;

            userAccount[msg.sender] =
                userAccount[msg.sender] -
                Transfer_amount -
                transfer_tax;
            userAccount[ReceiverAddress] =
                userAccount[ReceiverAddress] +
                converted_rate;

            string memory str_forex_rate = Strings.toString(forex_rate);
            string memory result_note = string(
                abi.encodePacked(
                    "Transfer Successful! With a deduction of ",
                    str_forex_rate,
                    "% foriegn currency exchange tax."
                )
            );
            return (result_note);
        }
        return ("Invalid Credentials..!");
    }

    function CheckBalance(string memory Password)
        public
        view
        returns (string memory)
    {
        if (
            keccak256(abi.encodePacked(Pswd[msg.sender])) ==
            keccak256(abi.encodePacked(Password))
        ) {
            string memory str_balance = Strings.toString(
                userAccount[msg.sender]
            );
            string memory result_note;

            if (
                keccak256(abi.encodePacked(Bank_Name[msg.sender])) ==
                keccak256(abi.encodePacked("Bank of India"))
            ) {
                result_note = string(abi.encodePacked(str_balance, " INR"));
            } else if (
                keccak256(abi.encodePacked(Bank_Name[msg.sender])) ==
                keccak256(abi.encodePacked("Bank of America"))
            ) {
                result_note = string(abi.encodePacked(str_balance, " USD"));
            } else if (
                keccak256(abi.encodePacked(Bank_Name[msg.sender])) ==
                keccak256(abi.encodePacked("Bank of Japan"))
            ) {
                result_note = string(abi.encodePacked(str_balance, " YEN"));
            }

            return (result_note);
        }

        return ("Wrong Password..!");
    }

    function ChangePassword(
        string memory CurrentPassword,
        string memory NewPassword
    ) public returns (string memory) {
        if (
            keccak256(abi.encodePacked(Pswd[msg.sender])) ==
            keccak256(abi.encodePacked(CurrentPassword))
        ) {
            Pswd[msg.sender] = NewPassword;
            return ("Password Changed Successfully..!");
        }

        return ("Invalid Password..!");
    }

    function AccountExist() public view returns (bool) {
        return userExists[msg.sender];
    }
}
