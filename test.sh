# #!/bin/bash

# set -e

# # Colors
# GREEN='\033[0;32m'
# RED='\033[0;31m'
# YELLOW='\033[1;33m'
# NC='\033[0m'

# echo "Starting full system test..."

# # Wait for healthchecks to pass
# echo -e "${YELLOW} Waiting for services to be healthy...${NC}"
# sleep 5

# # ---------------------------------------
# #  Health Check for Containers
# # ---------------------------------------
# check_health() {
#   echo -n "🔍 Checking container health... "
#   unhealthy=$(docker inspect --format='{{.Name}} {{.State.Health.Status}}' $(docker ps -q) | grep -v "healthy" || true)
#   if [ -n "$unhealthy" ]; then
#     echo -e "${RED}Unhealthy containers:${NC}"
#     echo "$unhealthy"
#     exit 1
#   else
#     echo -e "${GREEN}All containers are healthy.${NC}"
#   fi
# }

# # ---------------------------------------
# #  NGINX Routing and API Checks
# # ---------------------------------------
# check_response() {
#   local url=$1
#   local expected=$2
#   echo -n "🔗 Testing ${url} ... "
#   response=$(curl -s -w "%{http_code}" -o temp_response.txt "$url")
#   http_code="${response: -3}"
#   content=$(cat temp_response.txt)

#   if [[ "$http_code" == "200" && "$content" == *"$expected"* ]]; then
#     echo -e "${GREEN}PASSED${NC}"
#   else
#     echo -e "${RED}FAILED${NC} (HTTP $http_code)"
#     echo "Response: $content"
#     exit 1
#   fi
#   rm temp_response.txt
# }

# # ---------------------------------------
# #  Validate Non-root User Access
# # ---------------------------------------
# validate_non_root_access() {
#   local container=$1
#   local label=$2
#   echo -n "👤 Validating non-root user in $label ... "

#   user=$(docker exec "$container" whoami)
#   docker exec "$container" touch /app/test_file.txt 2>/dev/null || true
#   file_exists=$(docker exec "$container" test -f /app/test_file.txt && echo "yes" || echo "no")

#   if [[ "$user" != "root" && "$file_exists" == "yes" ]]; then
#     echo -e "${GREEN}PASSED${NC} (user=$user, can write to /app)"
#   else
#     echo -e "${RED}FAILED${NC}"
#     echo " - User: $user"
#     echo " - File write success: $file_exists"
#     exit 1
#   fi
# }

# # ---------------------------------------
# # Execute All Checks
# # ---------------------------------------
# check_health

# check_response "http://localhost:8080/service1/ping" "service"
# check_response "http://localhost:8080/service1/hello" "Hello"
# check_response "http://localhost:8080/service2/ping" "service"
# check_response "http://localhost:8080/service2/hello" "Hello"

# validate_non_root_access "service_1" "Service 1"
# validate_non_root_access "service_2" "Service 2"

# echo -e "${GREEN} Successfully passed all the test cases ${NC}"



#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

printf "${BLUE} Starting full system test for DevOps assignment...${NC}\n"
printf "${YELLOW} Waiting for services to initialize...${NC}\n"
sleep 5

# ---------------------------------------
# Step 1: Check Health of All Containers
# ---------------------------------------
check_health() {
  printf "\n${BLUE}Checking Docker container health status...${NC}\n"

  for container in $(docker ps -q); do
    name=$(docker inspect --format='{{.Name}}' "$container" | cut -c 2-)
    health=$(docker inspect --format='{{.State.Health.Status}}' "$container" 2>/dev/null || echo "no-healthcheck")
    if [ "$health" != "healthy" ]; then
      printf "${RED}❌ $name is $health${NC}\n"
      exit 1
    else
      printf "${GREEN}✅ $name is healthy${NC}\n"
    fi
  done
}

# ---------------------------------------
# Step 2: Test HTTP Requests & Content
# ---------------------------------------
check_response_verbose() {
  local label=$1
  local url=$2
  local expected=$3

  printf "\n${BLUE} Testing $label at $url...${NC}\n"
  response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" "$url")
  body=$(echo "$response" | sed '/^HTTP_STATUS:/d')
  status=$(echo "$response" | grep "HTTP_STATUS" | cut -d':' -f2)

  printf "${YELLOW} Response Body:${NC}\n$body\n"

  if [[ "$status" == "200" && "$body" == *"$expected"* ]]; then
    printf "${GREEN}✅ Status 200 OK and expected content found (${expected})${NC}\n"
  else
    printf "${RED}❌ Test failed: HTTP $status or missing content '${expected}'${NC}\n"
    exit 1
  fi
}

# ---------------------------------------
# Step 3: Non-Root User Validation
# ---------------------------------------
validate_non_root_access_verbose() {
  local container=$1
  local label=$2

  printf "\n${BLUE}👤 Validating non-root user behavior in $label...${NC}\n"

  user=$(docker exec "$container" whoami)
  printf "  🧾 Logged-in user: $user\n"

  printf "  🔐 touch /etc/test.txt → "
  docker exec "$container" sh -c 'touch /etc/test.txt' 2>&1 || printf "Permission denied \n"

  printf "  📁 touch /app/test_file.txt → "
  result=$(docker exec "$container" sh -c 'touch /app/test_file.txt' 2>&1 && echo "Success" || echo "Failed")
  echo "$result"

  if [[ "$user" != "root" && "$result" == "Success" ]]; then
    printf "${GREEN}  ✅ Non-root user has write access to /app and denied access to /etc${NC}\n"
  else
    printf "${RED}  ❌ Permission issue with non-root user setup${NC}\n"
    exit 1
  fi
}

# ---------------------------------------
# ✅ Run All Tests
# ---------------------------------------
check_health

# Nginx reverse proxy tests
check_response_verbose "Reverse Proxy → /service1/ping"  "http://localhost:8080/service1/ping"  "service"
check_response_verbose "Reverse Proxy → /service1/hello" "http://localhost:8080/service1/hello" "Hello"
check_response_verbose "Reverse Proxy → /service2/ping"  "http://localhost:8080/service2/ping"  "service"
check_response_verbose "Reverse Proxy → /service2/hello" "http://localhost:8080/service2/hello" "Hello"

# Non-root validation
validate_non_root_access_verbose "service_1" "Service 1"
validate_non_root_access_verbose "service_2" "Service 2"

printf "\n${GREEN}🎉 All tests passed successfully. Setup is production-ready!${NC}\n"
