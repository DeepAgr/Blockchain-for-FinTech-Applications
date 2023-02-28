// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;

contract regulation {
    mapping(address => bool) BlockedAccount;

    mapping(address => uint256) RegulatorAccount;
    mapping(address => bool) public RegulatorExists;

    mapping(address => string) Regulator_Name;
    mapping(address => string) Regulator_Pswd;

    function OpenRegulatorAccount(
        string memory RegulatorName,
        string memory Password
    ) public returns (string memory) {
        require(
            RegulatorExists[msg.sender] == false,
            "Account Already Created"
        );

        RegulatorAccount[msg.sender] = 0;
        RegulatorExists[msg.sender] = true;

        Regulator_Name[msg.sender] = RegulatorName;
        Regulator_Pswd[msg.sender] = Password;

        string memory result_note = string(
            abi.encodePacked(
                "Congratulation ",
                RegulatorName,
                "! Account Created."
            )
        );
        return (result_note);
    }

    function PasswordChanger(
        string memory CurrentPassword,
        string memory NewPassword
    ) public returns (string memory) {
        if (
            keccak256(abi.encodePacked(Regulator_Pswd[msg.sender])) ==
            keccak256(abi.encodePacked(CurrentPassword))
        ) {
            Regulator_Pswd[msg.sender] = NewPassword;
            return ("Password Changed Successfully..!");
        }

        return ("Invalid Password..!");
    }

    function RegulatorExist() public view returns (bool) {
        return RegulatorExists[msg.sender];
    }

    function blocker(address BlockingAddress, string memory Password)
        public
        returns (string memory)
    {
        require(
            RegulatorExists[msg.sender] == true,
            "Account is not created..!"
        );

        if (
            keccak256(abi.encodePacked(Regulator_Pswd[msg.sender])) ==
            keccak256(abi.encodePacked(Password))
        ) {
            BlockedAccount[BlockingAddress] = true;
            RegulatorAccount[msg.sender] = RegulatorAccount[msg.sender] + 1;

            string memory result_note = string(
                abi.encodePacked("Account blocked successfully")
            );
            return (result_note);
        }

        return ("Invalid Credentials..!");
    }

    function BlockedAccountChecker(address Address) public view returns (bool) {
        require(BlockedAccount[Address] == true, "Account is not blocked.");

        return BlockedAccount[Address];
    }
}
