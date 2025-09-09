1. Namespace

A namespace in Kubernetes is like a logical cluster within a cluster.

It’s used to divide cluster resources between multiple users, teams, or environments.

🔹 Key points:

Helps organize and isolate resources.

Each namespace can have its own resources (pods, services, deployments, etc.).

Default namespaces:

default → for general workloads.

kube-system → for system-related components.

kube-public → public resources accessible by all users.

kube-node-lease → heartbeats for node availability.

👉 Example: You may use

dev namespace for development,

test for testing,

prod for production.

# Create namespace
kubectl create namespace dev

# Run pod in a namespace
kubectl run nginx --image=nginx -n dev

2. ReplicationController (RC)

Old mechanism in Kubernetes for ensuring a specified number of pod replicas are running.

If a pod fails, the ReplicationController will create a new one.

🔹 Key features:

Ensures desired number of pod replicas are always running.

Supports scaling up/down.

Limited selector capability (only equality-based selectors).

👉 Example:

apiVersion: v1
kind: ReplicationController
metadata:
  name: nginx-rc
spec:
  replicas: 3
  selector:
    app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx


⚠️ ReplicationController is deprecated and replaced by ReplicaSet.

3. ReplicaSet (RS)

The newer and improved version of ReplicationController.

Does everything RC does, but with advanced selectors.

🔹 Key differences vs. RC:

Supports set-based selectors (e.g., in, notin, exists).

Is the default workload manager used under Deployments.

Ensures self-healing (maintains desired replica count).

👉 Example:

apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: nginx-rs
spec:
  replicas: 3
  selector:
    matchExpressions:
      - key: app
        operator: In
        values:
          - nginx
          - web
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx


apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: rs-example
spec:
  replicas: 3
  selector:
    matchExpressions:
      - key: env
        operator: In
        values:
          - prod
          - staging
      - key: tier
        operator: NotIn
        values:
          - frontend
  template:
    metadata:
      labels:
        env: prod
        tier: backend
    spec:
      containers:
      - name: app
        image: nginx




apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: my-rs
  labels:
    name: demo-app
spec:
  template:
    metadata:
      labels:
        app: demo-app
    spec:
      containers:
        - name: demo-container
          image: httpd:latest 
          ports:
          - name: http
            containerPort: 80
  selector:
    matchLabels:
      app: demo-app

  replicas: 5




🔹 What are selectors in Kubernetes?

Selectors define which pods belong to a ReplicaSet/Deployment/Service.

Equality-based selectors → key = value, key != value

Set-based selectors → in, notin, exists, doesnotexist

Equality selectors are simple, but set-based selectors are more flexible.

🔹 Set-based selectors examples
1. in

Matches if the label’s value is in a given list.

selector:
  matchExpressions:
    - key: env
      operator: In
      values:
        - dev
        - test


👉 This will select pods with labels:

env=dev OR env=test

2. notin

Matches if the label’s value is NOT in the given list.

selector:
  matchExpressions:
    - key: tier
      operator: NotIn
      values:
        - frontend


👉 This will select pods where tier label is anything except frontend.

3. exists

Matches if the label key is present, regardless of value.

selector:
  matchExpressions:
    - key: app
      operator: Exists


👉 This will select pods that have an app label, no matter what value it has.

4. doesnotexist

Matches if the label key is missing.

selector:
  matchExpressions:
    - key: debug
      operator: DoesNotExist


👉 This will select pods that do not have the debug label at all.

🔹 Example ReplicaSet using set-based selectors
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: rs-example
spec:
  replicas: 3
  selector:
    matchExpressions:
      - key: env
        operator: In
        values:
          - prod
          - staging
      - key: tier
        operator: NotIn
        values:
          - frontend
  template:
    metadata:
      labels:
        env: prod
        tier: backend
    spec:
      containers:
      - name: app
        image: nginx


👉 This ReplicaSet will select pods where:

env is either prod OR staging

tier is NOT frontend




1. Deployments vs StatefulSets

Kubernetes offers different controllers to manage Pods depending on application needs.

Deployment

Use Case: Stateless applications (e.g., web servers, APIs).

Pod Identity: Pods are interchangeable, no fixed identity.

Scaling: Easy horizontal scaling, any Pod can serve traffic.

Storage: Usually uses emptyDir or shared Persistent Volumes.

Updates: Supports rolling updates and rollbacks.

👉 Example apps: Nginx, Apache, Frontend UI, REST APIs.

StatefulSet

Use Case: Stateful applications (e.g., databases, Kafka, Redis).

Pod Identity: Each Pod has a unique, sticky identity (e.g., pod-0, pod-1).

Scaling: Pods created in order (0 → 1 → 2) and terminated in reverse order.

Storage: Uses PersistentVolumeClaims (PVCs) for stable storage.

Updates: Ordered, controlled updates.

👉 Example apps: MySQL, Cassandra, MongoDB, Elasticsearch.

Key Differences
Feature	Deployment (Stateless)	StatefulSet (Stateful)
Pod Identity	Random, interchangeable	Stable, ordered
Scaling	Simple, fast	Sequential, careful
Storage	Shared/ephemeral	Dedicated Persistent Volumes
Use Cases	Web servers, APIs	Databases, Queues, Caches
Update Strategy	Rolling updates	Ordered updates

2. YAML Manifests
Deployment Manifest (Nginx Example)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80



StatefulSet Manifest (MySQL Example)
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql-statefulset
spec:
  serviceName: "mysql"
  replicas: 3
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: mysql-data
          mountPath: /var/lib/mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: root123
  volumeClaimTemplates:
  - metadata:
      name: mysql-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi



3. DaemonSet
What is a DaemonSet?

A DaemonSet ensures that one Pod runs on every (or selected) node in the cluster.
Whenever a new node is added, the DaemonSet automatically schedules a Pod on it.

Use Cases

Running cluster-wide agents:

Log collection agents (Fluentd, Logstash, Filebeat)

Monitoring agents (Prometheus Node Exporter, Datadog Agent)

Networking components (CNI plugins, kube-proxy)

DaemonSet Manifest (Node Exporter Example)
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      containers:
      - name: node-exporter
        image: prom/node-exporter
        ports:
        - containerPort: 9100







4. Teaching Flow (How to Explain in Class)

Start with analogy

Deployment: Like a food court where all counters serve the same food.

StatefulSet: Like a bank locker – each locker (Pod) has a fixed identity.

DaemonSet: Like a security guard on each floor of a building.

Show diagrams

Deployment: identical Pods behind a load balancer.

StatefulSet: ordered Pods with storage.

DaemonSet: one Pod per node.

Hands-on exercise

Deploy an Nginx Deployment.

Deploy a MySQL StatefulSet.

Deploy a Node Exporter DaemonSet.

👉 Would you like me to also create diagrams/visual slides for these (Deployment vs StatefulSet vs DaemonSet) so your trainers can use them while teaching?



StateFull Sets

apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: my-ss
spec: 
  selector:
    matchLabels:
      mylabelsname: my-ss
  replicas: 4 
  template:
    metadata:
      name: my-ss
      labels:
        mylabelsname: my-ss
    spec:
      containers:
      - name: ss-container
        image: richardchesterwood/k8s-fleetman-webapp-angular:release0-5


configmap

apiVersion: v1
kind: ConfigMap
metadata: 
  name: my-config
data:
  dbpssword: "production"
  dbusername: "192.168.1.1"


cm-pod

apiVersion: v1
kind: Pod
metadata: 
  name: my-pod
spec:
  containers:
   - name: my-container
     image: nginx
     envFrom:
     - configMapRef:
         name: my-config 



apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
data:
  username: dXNlcg==         # base64("user")
  password: cGFzc3dvcmQ=     # base64("password")

  
apiVersion: v1
kind: Pod
metadata:
  name: secret-env-demo
spec:
  containers:
    - name: app
      image: nginx
      env:
        - name: DB_USER
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: username
        - name: DB_PASS
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: password


## HPA


AutoScaling in Kubernetes
1. What is AutoScaling?

AutoScaling in Kubernetes refers to the ability to automatically adjust resources (Pods, Nodes, or Clusters) based on load or usage metrics, ensuring optimal performance and resource utilization.

2. Types of AutoScaling in Kubernetes
a) Horizontal Pod Autoscaler (HPA)

Scales pods horizontally (increases/decreases the number of replicas).

Based on CPU, memory, or custom metrics (e.g., QPS).

Example: If CPU > 80%, add more pod replicas.

👉 Command:

kubectl autoscale deployment <deployment-name> --cpu-percent=80 --min=2 --max=10

b) Vertical Pod Autoscaler (VPA)

Adjusts resources of pods vertically (changes CPU/memory requests and limits of containers).

Useful for workloads with fluctuating resource needs.

It can recommend, automatically apply, or just observe.

👉 Modes:

Off (just recommend),

Auto (apply automatically),

Initial (set only at pod creation).

c) Cluster Autoscaler (CA)

Scales the number of nodes in the cluster.

Works with cloud providers like AWS (EKS), GCP (GKE), Azure (AKS).

If pods are unscheduled due to insufficient resources → adds nodes.

If nodes are underutilized → removes them.

3. HPA Manifest Example

Let’s create an HPA for a Deployment that scales between 2 and 10 replicas when average CPU usage is more than 50%.

Deployment (example app)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:latest
          ports:
            - containerPort: 80
          resources:                # required for HPA to monitor CPU
            requests:
              cpu: 100m
            limits:
              cpu: 200m

Horizontal Pod Autoscaler (HPA)
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
spec:
  scaleTargetRef:              # Target: Deployment
    apiVersion: apps/v1
    kind: Deployment
    name: nginx-deployment
  minReplicas: 2               # Minimum replicas
  maxReplicas: 10              # Maximum replicas
  metrics:
    - type: Resource
      resource:
        name: cpu              # Scale based on CPU
        target:
          type: Utilization
          averageUtilization: 50



1. Introduction to Ingress

In Kubernetes, Ingress is an API object that manages external access to services in a cluster.

It provides HTTP and HTTPS routing to services based on rules like hostnames or paths.

Without Ingress, external access is typically managed using:

NodePort

LoadBalancer

External IPs

➡️ Ingress gives a centralized way to manage traffic routing instead of exposing every service individually.

2. Why Use Ingress?

Centralized routing instead of creating multiple LoadBalancers/NodePorts.

Host-based and path-based routing.

SSL/TLS termination at the edge.

Load balancing between multiple services.

Rewrite/redirect URLs.

Save costs (fewer LoadBalancers needed in cloud).


3. Ingress vs Ingress Controller

Ingress: A set of rules for routing external traffic to services.

Ingress Controller: The actual implementation (pod) that reads Ingress rules and configures a reverse proxy/load balancer (like NGINX, HAProxy, Traefik, Istio Gateway).


4. Popular Ingress Controllers

NGINX Ingress Controller (most widely used, supported by Kubernetes community).

HAProxy Ingress.

Traefik.

Kong Ingress Controller.

Istio Gateway (service mesh focused).




Deploymentdemo

apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp-deployment
  namespace: fleetman
spec:
  selector:
    matchLabels:
      mylabelsname: webapp2
  replicas: 4 
  template:
    metadata:
      name: webapp
      labels:
        mylabelsname: webapp2
    spec:
      containers:
      - name: webapp
        image: richardchesterwood/k8s-fleetman-webapp-angular:release0-5



        

# Ingress file

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata: 
  name: cbz-ingress
  labels:
    app: cbz-ingress
spec:
  ingressClassName: nginx 
  rules:
    - host: "cbz.com"
      http:
        paths: 
          - pathType: Prefix
            path: "/"
            backend:
              service: 
                name: home-service
                port: 
                  number: 80
    - host: "mobile.cbz.com"
      http:
        paths: 
          - pathType: Prefix
            path: "/"
            backend:
              service: 
                name: mobile-service
                port: 
                  number: 80
    - host: "laptop.cbz.com"
      http:
        paths: 
          - pathType: Prefix
            path: "/"
            backend:
              service: 
                name: laptop-service
                port: 
                  number: 80



# Ingress path base Routing

# #Corrected ingresssfile
# apiVersion: networking.k8s.io/v1
# kind: Ingress
# metadata:
#   name: cbz-ingress
#   annotations:
#     nginx.ingress.kubernetes.io/rewrite-target: /$2
# spec:
#   ingressClassName: nginx
#   rules:
#     - host: a1966b12a9c4e4b44aae837ab4d48cd9-2070860083.eu-north-1.elb.amazonaws.com
#       http:
#         paths:
#           - path: /mobile(/|$)(.*)
#             pathType: ImplementationSpecific
#             backend:
#               service:
#                 name: mobile-service
#                 port:
#                   number: 80
#           - path: /laptop(/|$)(.*)
#             pathType: ImplementationSpecific
#             backend:
#               service:
#                 name: laptop-service
#                 port:
#                   number: 80
#           - path: /(.*)
#             pathType: ImplementationSpecific
#             backend:
#               service:
#                 name: home-service
#                 port:
#                   number: 80


# Ingress controller (Nginx)
 kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.1/deploy/static/provider/cloud/deploy.yaml



# Edit /etc/hosts file in your laptop

Ipv4 domain names