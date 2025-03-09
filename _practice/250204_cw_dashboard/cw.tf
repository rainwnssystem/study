resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "cg-dashboard"
  dashboard_body = jsonencode({
    "widgets" : [
      {
        "type" : "metric",
        "x" : 0,
        "y" : 0,
        "width" : 16,
        "height" : 6,
        "properties" : {
          "metrics" : [
            [
              "cg",
              "StartSession",
              {
                "label" : "SSM Access: $${LAST}",
                "region" : "ap-northeast-2"
              }
            ]
          ],
          "view" : "timeSeries",
          "stacked" : false,
          "region" : "ap-northeast-2",
          "stat" : "Sum",
          "period" : 300,
          "annotations" : {
            "horizontal" : [
              {
                "color" : "#ffbb78",
                "label" : "Warning",
                "value" : 10,
                "fill" : "above"
              }
            ]
          },
          "yAxis" : {
            "left" : {
              "showUnits" : false
            }
          },
          "title" : "SSM Access Count"
        }
      }
    ]
  })
}