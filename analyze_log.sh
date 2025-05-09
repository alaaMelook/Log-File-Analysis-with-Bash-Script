#!/bin/bash

LOGFILE="access.log"

# Check if the log file exists
if [[ ! -f "$LOGFILE" ]]; then
    echo "Error: Log file $LOGFILE not found."
    exit 1
fi

echo "Log File Analysis Report"
echo "======================="

# Request Counts
TOTAL_REQUESTS=$(wc -l < "$LOGFILE")
GET_REQUESTS=$(grep '"GET' "$LOGFILE" | wc -l)
POST_REQUESTS=$(grep '"POST' "$LOGFILE" | wc -l)

echo "Total number of requests: $TOTAL_REQUESTS"
echo "Number of GET requests: $GET_REQUESTS"
echo "Number of POST requests: $POST_REQUESTS"
echo ""

# Unique IP Addresses
UNIQUE_IPS=$(awk '{print $1}' "$LOGFILE" | sort | uniq | wc -l)

echo "Number of unique IPs: $UNIQUE_IPS"
echo "Details of GET and POST requests per IP:"
awk '{print $1}' "$LOGFILE" | sort | uniq | while read -r ip; do
    GET_COUNT=$(grep "$ip" "$LOGFILE" | grep '"GET' | wc -l)
    POST_COUNT=$(grep "$ip" "$LOGFILE" | grep '"POST' | wc -l)
    echo "IP: $ip, GET: $GET_COUNT, POST: $POST_COUNT"
done
echo ""

# Failure Requests
FAILED_REQUESTS=$(awk '$9 ~ /^[4-5][0-9][0-9]$/ {count++} END {print count}' "$LOGFILE")
FAILED_REQUESTS=${FAILED_REQUESTS:-0}
FAILED_PERCENTAGE=$(echo "scale=2; ($FAILED_REQUESTS / $TOTAL_REQUESTS) * 100" | bc)

echo "Number of failed requests (4xx or 5xx): $FAILED_REQUESTS"
echo "Percentage of failed requests: $FAILED_PERCENTAGE%"
echo ""

# Most Active IP
TOP_IP=$(awk '{print $1}' "$LOGFILE" | sort | uniq -c | sort -nr | head -1 | awk '{print $2}')
TOP_IP_COUNT=$(awk '{print $1}' "$LOGFILE" | sort | uniq -c | sort -nr | head -1 | awk '{print $1}')

echo "Most active IP: $TOP_IP (Number of requests: $TOP_IP_COUNT)"
echo ""

# Daily Request Averages
DAYS=$(awk -F'[:[]' '{print $2}' "$LOGFILE" | sort | uniq | wc -l)
AVG_REQUESTS=$(echo "scale=2; $TOTAL_REQUESTS / $DAYS" | bc)

echo "Number of days: $DAYS"
echo "Average requests per day: $AVG_REQUESTS"
echo ""

# Days with Highest Failures
echo "Days with the highest number of failed requests:"
awk -F'[:[]' '$9 ~ /^[4-5][0-9][0-9]$/ {print $2}' "$LOGFILE" | sort | uniq -c | sort -nr | head -5
echo ""

# Requests by Hour
echo "Number of requests per hour:"
awk -F'[:[]' '{print $3}' "$LOGFILE" | sort | uniq -c | sort -n
echo ""

# Status Codes Breakdown
echo "Status codes breakdown:"
awk '{print $9}' "$LOGFILE" | sort | uniq -c | sort -nr
echo ""

# Most Active IP by Method
TOP_GET_IP=$(grep '"GET' "$LOGFILE" | awk '{print $1}' | sort | uniq -c | sort -nr | head -1 | awk '{print $2}')
TOP_GET_COUNT=$(grep '"GET' "$LOGFILE" | awk '{print $1}' | sort | uniq -c | sort -nr | head -1 | awk '{print $1}')
TOP_POST_IP=$(grep '"POST' "$LOGFILE" | awk '{print $1}' | sort | uniq -c | sort -nr | head -1 | awk '{print $2}')
TOP_POST_COUNT=$(grep '"POST' "$LOGFILE" | awk '{print $1}' | sort | uniq -c | sort -nr | head -1 | awk '{print $1}')

echo "Most active IP using GET: $TOP_GET_IP (Count: $TOP_GET_COUNT)"
echo "Most active IP using POST: $TOP_POST_IP (Count: $TOP_POST_COUNT)"
echo ""

# Patterns in Failure Requests
echo "Failed requests by hour:"
awk -F'[:[]' '$9 ~ /^[4-5][0-9][0-9]$/ {print $3}' "$LOGFILE" | sort | uniq -c | sort -n
echo ""
