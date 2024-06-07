;;; rosbag-info.el --- An Emacs mode to view informaion about ROS/ROS2 bag files  -*- lexical-binding: t; -*-

;; Copyright (C) 2024  Abdelhak Bougouffa

;; Author: Abdelhak Bougouffa <abougouffa@fedoraproject.org>
;; Keywords: tools, data, hardware, hardware

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:


(defgroup ros-info nil
  "ROS info mode."
  :group 'tools)

(defcustom rosbag-info-mcap-command "mcap-cli"
  "ROS 2 MCAP command."
  :group 'ros-info
  :type '(choice file string))

(defcustom rosbag-info-rosbag-command "rosbag"
  "ROS 1 \"rosbag\" command."
  :group 'ros-info
  :type '(choice file string))

(defcustom rosbag-info-ros2-command "ros2"
  "ROS 2 \"ros2\" command."
  :group 'ros-info
  :type '(choice file string))

;;;###autoload
(dolist (ext-mode '(("\\.rviz\\'"   . conf-unix-mode)
                    ("\\.urdf\\'"   . xml-mode)
                    ("\\.xacro\\'"  . xml-mode)
                    ("\\.launch\\'" . xml-mode)
                    ("\\.msg\\'"    . gdb-script-mode)
                    ("\\.srv\\'"    . gdb-script-mode)
                    ("\\.action\\'" . gdb-script-mode)))
  (add-to-list 'auto-mode-alist ext-mode))

(when (cl-some (lambda (cmd) (and cmd (executable-find cmd)))
               (list rosbag-info-mcap-command rosbag-info-rosbag-command rosbag-info-ros2-command)))

;; A mode to display info from ROS bag files (via MCAP)

;;;###autoload
(define-derived-mode rosbag-info-mode conf-colon-mode "ROS bag"
  "Major mode for viewing ROS/ROS2 bag files."
  :interactive nil
  (buffer-disable-undo)
  (set-buffer-modified-p nil)
  (setq-local buffer-read-only t
              truncate-lines t))

;;;###autoload
(defun rosbag-info-mode-open-file (file)
  "Browse the contents of a ROS bag FILE (v1, SQLite, or MCAP)."
  (interactive "fROS/ROS2/MCAP bag file name: ")
  (let ((bag-format (file-name-extension file)))
    (if (not (member bag-format '("bag" "db3" "mcap")))
        (user-error "File \"%s\" doesn't seem to be a ROS/ROS2 bag file"
                    (file-name-nondirectory file))
      (let ((buffer-read-only nil)
            (buff (get-buffer-create
                   (format "*ROS (%s) %s*" (upcase bag-format) (file-name-nondirectory file)))))
        (pop-to-buffer buff)
        (pcase bag-format
          ("bag"
           (call-process rosbag-info-rosbag-command
                         nil buff nil "info" (expand-file-name file)))
          ("db3"
           (call-process rosbag-info-ros2-command
                         nil buff nil "bag" "info" (expand-file-name file)))
          ("mcap"
           (call-process rosbag-info-mcap-command
                         nil buff nil "info" (expand-file-name file)))
          (rosbag-info-mode))))))


(provide 'rosbag-info)
;;; rosbag-info.el ends here

