package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/kinesis"
)

const (
	streamName = "wsi-stream" // Kinesis Data Streams 이름으로 교체
)

var kinesisClient *kinesis.Client

func main() {
	// AWS 구성 로드
	cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithRegion("ap-northeast-2")) // 서울 리전
	if err != nil {
		log.Fatalf("AWS 구성 로드 실패: %v", err)
	}

	// Kinesis 클라이언트 초기화
	kinesisClient = kinesis.NewFromConfig(cfg)

	// HTTP 핸들러 설정
	http.HandleFunc("/", logRequest)

	// 웹 서버 시작
	fmt.Println("서버 시작: http://localhost:8080")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatalf("서버 시작 실패: %v", err)
	}
}

func logRequest(w http.ResponseWriter, r *http.Request) {
	// 요청 정보 로깅
	logEntry := fmt.Sprintf("%s - [%s] \"%s %s %s\" %s",
		r.RemoteAddr,
		time.Now().Format(time.RFC1123),
		r.Method,
		r.RequestURI,
		r.Proto,
		r.UserAgent(),
	)

	// Kinesis에 로그 전송
	err := sendToKinesis([]byte(logEntry))
	if err != nil {
		http.Error(w, "로그 전송 실패", http.StatusInternalServerError)
		return
	}

	// 응답
	fmt.Fprintln(w, "요청이 처리되었습니다.")
}

func sendToKinesis(data []byte) error {
	// Kinesis에 PutRecord 요청
	_, err := kinesisClient.PutRecord(context.TODO(), &kinesis.PutRecordInput{
		Data:         data,
		StreamName:   aws.String(streamName),
		PartitionKey: aws.String("logs"), // 적절한 파티션 키로 교체
	})
	return err
}