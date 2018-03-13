(in-package :mlsspbc.resources)

;; 知識ノード
(defun knowledge-struct ()
  (let ((node-content (get-parameter "node-content"))
	(lesson-id (get-parameter "lesson-id")))
    (format nil "~A" "[{id: 1, label: 'Node 1', title: 'I have a popup!'},{id: 2, label: 'Node 2', title: 'I have a popup!'},{id: 3, label: 'Node 3', title: 'I have a popup!'},{id: 4, label: 'このノードはだめだ', title: 'I have a popup!'},{id: 5, label: 'Node 5', title: 'I have a popup!'}]")))

;; 知識エッジ
(defun knowledge-edge ()
  (let ((node-content (get-parameter "node-content"))
	(lesson-id (get-parameter "lesson-id")))
    (format nil "~A" "[{from: 1, to: 3},{from: 1, to: 2},{from: 2, to: 4},{from: 2, to: 5}]")))
