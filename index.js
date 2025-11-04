const questions = [
    {
        id: 1,
        question: "What is AWS?",
        options: [
            "A programming language",
            "A cloud service provider",
            "A database software",
            "A web browser"
        ],
        correctAnswer: 1
    },
    {
        id: 2,
        question: "What is an EC2 instance used for?",
        options: [
            "Storing files",
            "Running virtual servers",
            "Sending emails",
            "Monitoring network traffic"
        ],
        correctAnswer: 1
    },
    {
        id: 3,
        question: "What does S3 stand for in AWS?",
        options: [
            "Simple Storage Service",
            "Secure Server System",
            "System Storage Solution",
            "Simple Server Service"
        ],
        correctAnswer: 0
    },
    {
        id: 4,
        question: "What is an AWS Region?",
        options: [
            "A single data center",
            "A geographic area with multiple data centers",
            "A type of EC2 instance",
            "A storage bucket"
        ],
        correctAnswer: 1
    },
    {
        id: 5,
        question: "Which AWS service is used for relational databases?",
        options: [
            "EC2",
            "RDS",
            "S3",
            "Lambda"
        ],
        correctAnswer: 1
    },
    {
        id: 6,
        question: "What is the main benefit of AWS Auto Scaling?",
        options: [
            "Automatically updates your applications",
            "Automatically adjusts the number of instances based on demand",
            "Automatically creates backups",
            "Automatically monitors network traffic"
        ],
        correctAnswer: 1
    },
    {
        id: 7,
        question: "What is the purpose of IAM in AWS?",
        options: [
            "To store data",
            "To manage user access and permissions",
            "To launch virtual servers",
            "To monitor website traffic"
        ],
        correctAnswer: 1
    },
    {
        id: 8,
        question: "Which AWS service is used to run serverless code?",
        options: [
            "EC2",
            "Lambda",
            "S3",
            "RDS"
        ],
        correctAnswer: 1
    },
    {
        id: 9,
        question: "What is CloudFront used for?",
        options: [
            "To store files",
            "To deliver content via a Content Delivery Network (CDN)",
            "To run virtual servers",
            "To manage users"
        ],
        correctAnswer: 1
    },
    {
        id: 10,
        question: "Which AWS service is best for object-based storage?",
        options: [
            "EC2",
            "S3",
            "Lambda",
            "RDS"
        ],
        correctAnswer: 1
    }
];

let currentQuestionIndex = 0;
let answers = {};
let totalScore = 0;

// DOM elements
const questionText = document.getElementById('questionText');
const optionsContainer = document.getElementById('optionsContainer');
const currentQuestionSpan = document.getElementById('currentQuestion');
const totalQuestionsSpan = document.getElementById('totalQuestions');
const progressFill = document.getElementById('progressFill');
const prevBtn = document.getElementById('prevBtn');
const nextBtn = document.getElementById('nextBtn');
const submitBtn = document.getElementById('submitBtn');
const quizForm = document.getElementById('quizForm');
const completionMessage = document.getElementById('completionMessage');
const emailDiv = document.getElementById('emailDiv');
const useremail = document.getElementById('useremail');
const emailSubmitBtn = document.getElementById('emailSubmitBtn');


// Initialize quiz
function initializeQuiz() {
    totalQuestionsSpan.textContent = questions.length;
    displayQuestion();
}

// Display current question
function displayQuestion() {
    const question = questions[currentQuestionIndex];
    
    questionText.textContent = question.question;
    currentQuestionSpan.textContent = currentQuestionIndex + 1;
    
    // Update progress bar
    const progressPercentage = ((currentQuestionIndex + 1) / questions.length) * 100;
    progressFill.style.width = progressPercentage + '%';
    
    // Clear previous options
    optionsContainer.innerHTML = '';
    
    // Create options
    question.options.forEach((option, index) => {
        const optionDiv = document.createElement('div');
        optionDiv.className = 'option';
        
        const input = document.createElement('input');
        input.type = 'radio';
        input.id = `option${index}`;
        input.name = 'answer';
        input.value = index;
        
        // Check if this option was previously selected
        if (answers[question.id] === index) {
            input.checked = true;
        }
        
        const label = document.createElement('label');
        label.htmlFor = `option${index}`;
        label.textContent = option;
        
        optionDiv.appendChild(input);
        optionDiv.appendChild(label);
        optionsContainer.appendChild(optionDiv);
    });
    
    // Update navigation buttons
    updateNavigationButtons();
}

// Update navigation button states
function updateNavigationButtons() {
    prevBtn.disabled = currentQuestionIndex === 0;
    
    if (currentQuestionIndex === questions.length - 1) {
        nextBtn.style.display = 'none';
        submitBtn.style.display = 'inline-block';
    } else {
        nextBtn.style.display = 'inline-block';
        submitBtn.style.display = 'none';
    }
}

// Save current answer
function saveCurrentAnswer() {
    const selectedOption = document.querySelector('input[name="answer"]:checked');
    if (selectedOption) {
        answers[questions[currentQuestionIndex].id] = parseInt(selectedOption.value);
    }
}

// Calculate total score
function calculateScore() {
    let score = 0;
    questions.forEach(question => {
        const userAnswer = answers[question.id];
        if (userAnswer === question.correctAnswer) {
            score++;
        }
    });
    return score;
}


// Navigate to previous question
function previousQuestion() {
    saveCurrentAnswer();
    if (currentQuestionIndex > 0) {
        currentQuestionIndex--;
        displayQuestion();
    }
}

// Navigate to next question
function nextQuestion() {
    saveCurrentAnswer();
    if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
        displayQuestion();
    }
}

// Event listeners
prevBtn.addEventListener('click', previousQuestion);
nextBtn.addEventListener('click', nextQuestion);
quizForm.addEventListener('submit', submitQuiz);
document.addEventListener('DOMContentLoaded', initializeQuiz);
emailSubmitBtn.addEventListener('click', submitEmail);

// Submit quiz function
async function submitQuiz(event) {
    event.preventDefault();
    saveCurrentAnswer(); // Save the current answer

    // Calculate final score
    totalScore = calculateScore();

// Show completion message and email input
    document.querySelector('.quiz-container').style.display = 'none';
    document.querySelector('.container').style.display = 'none';
    completionMessage.style.display = 'block';
    emailDiv.style.display = 'block';
    useremail.style.display = 'block';
    emailSubmitBtn.style.display = 'inline-block';

}

// Retry quiz on user input

function retryQuiz() {
            currentQuestionIndex = 0;
            answers = {};
            completionMessage.style.display = 'none';
            emailDiv.style.display = 'none';
            document.querySelector('.quiz-container').style.display = 'block';
            document.querySelector('.container').style.display = 'block';
            useremail.style.display = 'none';
            emailSubmitBtn.style.display = 'none';
            displayQuestion();
        }

    // Send score and email results to AWS after user inputs email

    async function submitEmail() {
        const email = useremail.value.trim();

        if (!email) {
            alert("Please enter an email before submitting!");
            return;
        }

    // Provide own API Gateway invoke URL for the fetch

        try {
            const response = await fetch(API_URL, {
                method: "POST",
                headers: {"Content-Type": "application/json"},
                body: JSON.stringify({
                    email: useremail.value,
                    totalScore: totalScore
                })
            });

            const data = await response.json();
            console.log("Score and email saved:", data);
            alert("You have successfully submitted your email! You may retake the test or leave.");
        }
        catch (err) {
            console.error("Error submitting quiz:", err);
        }
    }



