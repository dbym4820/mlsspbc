(in-package :mlsspbc.resources)

(defun knowledge-struct ()
  (let ((slide-id (get-parameter "slide-id")))
    (format nil "~A" "{
  \"nodes\": [
    {
      \"id\": \"n0\",
      \"label\": \"A node\",
      \"x\": 0,
      \"y\": 0,
      \"size\": 300
    },
    {
      \"id\": \"n1\",
      \"label\": \"Another node\",
      \"x\": 3,
      \"y\": 1,
      \"size\": 300
    },
    {
      \"id\": \"n2\",
      \"label\": \"And a last one\",
      \"x\": 1,
      \"y\": 3,
      \"size\": 100
    }
  ],
  \"edges\": [
    {
      \"id\": \"e0\",
      \"source\": \"n0\",
      \"target\": \"n1\"
    },
    {
      \"id\": \"e1\",
      \"source\": \"n1\",
      \"target\": \"n2\"
    },
    {
      \"id\": \"e2\",
      \"source\": \"n2\",
      \"target\": \"n0\"
    }
  ]
}")))
