pragma solidity ^0.5.0;

import "./Ownable.sol";

contract VerifierInterface is Ownable {
    function setPoapToken(address _address) public;
    function isUserAbleToSubmitAnswer(address _user) public pure returns (bool);
}

contract Poll is Ownable {

    VerifierInterface verifierInterface;
    uint8 questionIdCounter;
    mapping (uint8 => Question) questions;

    struct Question {
        string questionText;
        uint8 id;
        uint8 answerIdCounter;
        mapping (uint8 => Answer) possibleAnswers;
    }

    struct Answer {
        string answerText;
        uint8 id;
        uint8 poll;
    }

    constructor (address _verifierInterfaceAddress) public {
        verifierInterface = VerifierInterface(_verifierInterfaceAddress);
        questionIdCounter = 0;
    }

    function isValidQuestionId(uint8 _questionId) internal view returns (bool) {
        return _questionId >= 0 && _questionId < questionIdCounter;
    }

    modifier onlyValidQuestionIds(uint8 _questionId) {
        require(isValidQuestionId(_questionId), "Invalid question ID");
        _;
    }

    function isValidAnswerId(uint8 _questionId, uint8 _answerId) internal onlyValidQuestionIds(_questionId) view returns (bool) {
       return _answerId >= 0 && _questionId < questions[_questionId].answerIdCounter;
    }

    modifier onlyValidAnswerIds(uint8 _questionId, uint8 _answerId) {
        require(isValidAnswerId(_questionId, _answerId), "Invalid answer ID");
        _;
    }

    function setPoapToken(address _address) public /*onlyOwner*/ {
        verifierInterface.setPoapToken(_address);
    }

    function addQuestion(string calldata _questionText) external /*onlyOwner*/ returns (uint8) {
        Question memory q;
        q.questionText = _questionText;
        q.id = questionIdCounter;
        q.answerIdCounter = 0;
        questions[questionIdCounter] = q;

        questionIdCounter++;
        return q.id;
    }

    function addAnswer(uint8 _questionId, string calldata _answerText) external onlyValidQuestionIds(_questionId) /*OnlyOwner*/ returns (uint8) {
        uint8 answerId = questions[_questionId].answerIdCounter;

        Answer memory a;
        a.answerText = _answerText;
        a.id = answerId;
        questions[_questionId].possibleAnswers[answerId] = a;

        questions[_questionId].answerIdCounter++;
        return answerId;
    }

    function getQuestion(uint8 _questionId) public onlyValidQuestionIds(_questionId) view returns (string memory) {
        return questions[_questionId].questionText;
    }

    function getAnswer(uint8 _questionId, uint8 _answerId) public onlyValidAnswerIds(_questionId, _answerId) view returns (string memory) {
        return questions[_questionId].possibleAnswers[_answerId].answerText;
    }

}