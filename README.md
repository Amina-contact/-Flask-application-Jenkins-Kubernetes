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
# Project structure:
 - app.py : Flask application which will print "Hello world"
 - test.py : Test cases for the application
 - Dockerfile : Contains commands to build and run the docker image
 - deployment.yaml : Kubernetes deployment file for the application
 - service.yaml : Kubernetes service file for the application
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

The pipelines should start running now and you should be able to see the status of the build on the page.
<h2>5. Create a Kubernetes deployment and service for the application</h2>
<li>Start minikube cluster</strong>:<code>minikube start</code></li><br>
<li>Create a new file named "deployment.yaml" in your project and add the below code</strong>:</li><br>
<pre class="notranslate"><code>
apiVersion: apps/v1
kind: Deployment
metadata:
 name: flask-hello-deployment # name of the deployment
 
spec:
 template: # pod defintion
   metadata:
     name: flask-hello # name of the pod
     labels:
       app: flask-hello
       tier: frontend
   spec:
     containers:
       - name: flask-hello
         image: dahmouniamina/flask:latest
 replicas: 3
 selector: # Mandatory, Select the pods which needs to be in the replicaset
   matchLabels:
     app: flask-hello
     tier: frontend
</code></pre>
<li>Test the deployment manually by running the following command</strong>:<code>kubectl apply -f deployment.yaml</code></li><br>
<li>Create a new file named "service.yaml" and add the following code</strong>:</li><br>
<pre class="notranslate"><code>
apiVersion: v1
kind: Service
metadata:
 name: flask-hello-service-nodeport # name of the service
 
spec:
 type: NodePort # Used for accessing a port externally
 ports:
   - port: 5000 # Service port
     targetPort: 5000 # Pod port, default: same as port
     nodePort: 30008 # Node port which can be used externally, default: auto-assign any free port
 selector: # Which pods to expose externally ?
   app: flask-hello
   tier: frontend
</code></pre>
<li>Test the service manually by running below commands</strong>:<code>kubectl apply -f service.yaml</code></li><br>
<li>Run below command to access the application on the browser</strong>:<code>minikube service flask-hello-service-nodeport</code></li><br>
#Conclusion
In this tutorial, we have tried to build a very simple CI/CD pipeline using jenkins and kubernetes. 
