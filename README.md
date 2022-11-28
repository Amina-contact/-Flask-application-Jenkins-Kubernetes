# Flask-application-Jenkins-Kubernetes
In this lab we are going to Build & deploy  a simple flask application using Jenkins and Kubernetes.
# Prerequisites :
 - Docker
 - Git and Github
 - Jenkins
 - Kubernetes
 - Linux machine
 - Python
 - Flask
 # Set up virtual Python environment:
 Virtual environment is a tool that helps to keep dependencies required by different projects separate by creating isolated python virtual environments for them. 
 This is one of the most important tools that most of Python developers use.
<li>Create the virtual environment named env</strong>:<code>py -m venv env</code></li>

<li>Activate the virtual environment</strong>:<code>source env/bin/activate</code></li>
<h2>1. Create a "Hello world" Flask application</h2>
<li>Install the flask module</strong>:<code>pip install flask</code></li><br>
<img src="https://github.com/Amina-contact/-Flask-application-Jenkins-Kubernetes/blob/master/Pictures/3.JPG">
<li>Create a new file named "app.py"</strong>:</li><br>
<img src="https://github.com/Amina-contact/-Flask-application-Jenkins-Kubernetes/blob/master/Pictures/4.JPG">
<li>Running the code</strong>:<code>python app.py</code> and it will start a web server on port number 5000</li><br>
<img src="https://github.com/Amina-contact/-Flask-application-Jenkins-Kubernetes/blob/master/Pictures/5.JPG">
<h2>2. Write test cases using pytest</h2>
<li>Install pytest module. We will use pytest for testing</strong>:<code>pip install pytest</code></li><br>
<img src="https://github.com/Amina-contact/-Flask-application-Jenkins-Kubernetes/blob/master/Pictures/7.JPG">
<li>Create a new file named "test.py" and add a basic test case</strong>:</li><br>
<img src="https://github.com/Amina-contact/-Flask-application-Jenkins-Kubernetes/blob/master/Pictures/8.JPG">
<li>Run the test file using pytest</strong>:<code>pytest test.py</code></li><br>
<h2>3. Dockerise the application</h2>
<li>Create a file named "Dockerfile" and add the below code</strong>:</li><br>
<pre class="notranslate"><code>
FROM python:2.7
COPY app.py test.py /app/
WORKDIR /app
RUN pip install flask pytest
CMD ["python", "app.py"]
</code></pre>
<li>Build the docker image</strong>:<code>docker build -t flask-app .</code></li><br>
<img src="https://github.com/Amina-contact/-Flask-application-Jenkins-Kubernetes/blob/master/Pictures/9.JPG">
<li>Run the application using docker image</strong>:<code>docker run -it -p 5000:5000 flask-app</code></li><br>
<img src="https://github.com/Amina-contact/-Flask-application-Jenkins-Kubernetes/blob/master/Pictures/10.JPG"><br>
<img src="https://github.com/Amina-contact/-Flask-application-Jenkins-Kubernetes/blob/master/Pictures/11.JPG">
<li>Run test</strong>:<code>docker run -it flask-app pytest test.py</code></li><br>
<img src="https://github.com/Amina-contact/-Flask-application-Jenkins-Kubernetes/blob/master/Pictures/12.JPG">
<h2>4. Create a Jenkins pipeline</h2>
<li>Create a Jenkins pipeline which will help in building, testing and deploying the application</strong>:</li><br>
<img src="https://github.com/Amina-contact/-Flask-application-Jenkins-Kubernetes/blob/master/Pictures/13.JPG">
<li>Write a pipeline script in Groovy for building, testing and deploying code</strong>:</li><br>
<pre class="notranslate"><code>
pipeline {
   agent any
  
   environment {
       DOCKER_HUB_REPO = "dahmouniamina/flask"
       CONTAINER_NAME = "flask"
 
   }
  
   stages {
       stage('Checkout') {
           steps {
               checkout([$class: 'GitSCM', branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/Amina-contact/-Flask-application-Jenkins-Kubernetes']]])
           }
       }
       stage('Build') {
           steps {
               echo 'Building..'
               sh 'docker image build -t $DOCKER_HUB_REPO:latest .'
           }
       }
       stage('Test') {
           steps {
               echo 'Testing..'
               sh 'docker stop $CONTAINER_NAME || true'
               sh 'docker rm $CONTAINER_NAME || true'
               sh 'docker run --name $CONTAINER_NAME $DOCKER_HUB_REPO /bin/bash -c "pytest && test.py"'
           }
       }
       stage('Deploy') {
           steps {
               echo 'Deploying....'
               sh 'docker stop $CONTAINER_NAME || true'
               sh 'docker rm $CONTAINER_NAME || true'
               sh 'docker run -d -p 5000:5000 --name $CONTAINER_NAME $DOCKER_HUB_REPO'
           }
       }
   }
}
</code></pre>
<img src="https://github.com/Amina-contact/-Flask-application-Jenkins-Kubernetes/blob/master/Pictures/13.JPG">
