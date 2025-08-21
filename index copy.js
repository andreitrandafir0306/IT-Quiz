const questions = [
    {
        id: 1,
        question: "Elementul principal de retenție al unei proteze totale este:",
        options: [
            "Gravitația",
            "Adeziunea salivară",
            "Stabilitatea ocluzală",
            "Presiunea atmosferică"
        ],
        correctAnswer: 1
    },
    {
        id: 2,
        question: "Funcția principală a planului de ocluzie în protetica totală este:",
        options: [
            "Determinarea liniei mediane",
            "Asigurarea esteticii",
            "Stabilirea dimensiunii verticale",
            "Crearea spațiului pentru limbă"
        ],
        correctAnswer: 2
    },
    {
        id: 3,
        question: "Principiul cel mai important în prepararea dinților pentru coroane este:",
        options: [
            "Îndepărtarea totală a smalțului",
            "Crearea retenției și rezistenței optime",
            "Reducerea excesivă a dintelui",
            "Crearea unei suprafețe rugoase"
        ],
        correctAnswer: 1
    },
    {
        id: 4,
        question: "Materialul de amprentă cel mai frecvent folosit în protetica fixă este:",
        options: [
            "Ghipsul",
            "Alginatele",
            "Siliconii de adiție",
            "Ceara"
        ],
        correctAnswer: 2
    },
    {
        id: 5,
        question: "Într-o proteză scheletală, rolul principal al croșetelor este:",
        options: [
            "Suport",
            "Stabilitate",
            "Retenție",
            "Estetică"
        ],
        correctAnswer: 2
    },
    {
        id: 6,
        question: "Indicația clasică pentru proteza totală este:",
        options: [
            "Lipsa a 2-3 dinți în zona laterală",
            "Edentație totală maxilară sau mandibulară",
            "Pierderea unui singur incisiv central",
            "Edentație unilaterală terminală"
        ],
        correctAnswer: 1
    },
    {
        id: 7,
        question: "Avantajul principal al dinților acrilici față de cei din porțelan este:",
        options: [
            "Rezistență mai mare la abraziune",
            "Fixare chimică bună pe baza acrilică",
            "Estetică superioară porțelanului",
            "Durabilitate mai mare"
        ],
        correctAnswer: 1
    },
    {
        id: 8,
        question: "Metoda cea mai utilizată pentru determinarea dimensiunii verticale de ocluzie este:",
        options: [
            "Relația centrică",
            "Sunetele fonetice",
            "Torus palatin",
            "Analiza radiologică"
        ],
        correctAnswer: 1
    },
    {
        id: 9,
        question: "Bara linguală este contraindicată atunci când:",
        options: [
            "Există spațiu vertical mare",
            "Torus lingualul este voluminos",
            "Arcadele sunt înguste",
            "Dinții sunt ușor înclinați lingual"
        ],
        correctAnswer: 1
    },
    {
        id: 10,
        question: "Obiectivul principal al tratamentului protetic este:",
        options: [
            "Prevenirea cariilor secundare",
            "Reabilitarea funcțiilor aparatului dento-maxilar",
            "Reducerea mobilității dentare",
            "Crearea de contacte premature"
        ],
        correctAnswer: 1
    }
];



let currentQuestionIndex = 0;
let answers = {};

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

// Submit quiz
function submitQuiz(event) {
    event.preventDefault();
    saveCurrentAnswer();
    
    // Prepare quiz results for submission
    const score = {
        answers: answers,
        totalQuestions: questions.length,
        timestamp: new Date().toISOString(),
        questions: questions
    };
    
    // Here you would typically send the results to your AWS backend
    // For now, we'll just log it and show completion message
    console.log('Quiz Results:', score);
    
    // Show completion message
    document.querySelector('.quiz-container').style.display = 'none';
    completionMessage.style.display = 'block';
}

// Event listeners
prevBtn.addEventListener('click', previousQuestion);
nextBtn.addEventListener('click', nextQuestion);
quizForm.addEventListener('submit', submitQuiz);

// Initialize the quiz when the page loads
document.addEventListener('DOMContentLoaded', initializeQuiz);

// Function to send results to AWS
async function getApiUrl() {
    const response = await fetch("index.js", { method: "HEAD" });
    const apiUrl = response.headers.get("x-amz-meta-api-url");
    return apiUrl;
}

getApiUrl().then(apiUrl => {
    console.log("Loaded API URL:", apiUrl);
    // later you can use it in fetch()
    fetch(apiUrl, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ userscore: score })
    })
    .then(res => res.json())
    .then(data => console.log("Result saved:", data))
    .catch(err => console.error(err));
});



