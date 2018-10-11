(in-package :loapeat.resources)

(defun slide-knowledge-struct ()
  (let ((node-id (get-parameter "node-id")))
    (format nil "~A" "[{id: 1, label: 'Node 1', title: 'I have a popup!'},{id: 2, label: 'Node 2', title: 'I have a popup!'},{id: 3, label: 'Node 3', title: 'I have a popup!'},{id: 4, label: 'Node 4', title: 'I have a popup!'},{id: 5, label: 'Node 5', title: 'I have a popup!'}]")))

(defun slide-knowledge-edge ()
  (let ((node-id (get-parameter "node-id")))
    (format nil "~A" "[{from: 1, to: 3},{from: 1, to: 2},{from: 2, to: 4},{from: 2, to: 5}]")))
