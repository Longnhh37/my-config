// Background collector monitoring MLX (mlx-lm) server lifecycle and loaded model.

use crate::state::SharedState;
use std::sync::OnceLock;
use std::time::Duration;
use tokio::process::Command;

const POLL_INTERVAL: Duration = Duration::from_secs(3);
const API_URL: &str = "http://localhost:8080/v1/models";
const REQUEST_TIMEOUT: Duration = Duration::from_secs(1);
const NOT_RUNNING_THRESHOLD: u32 = 2;

// ── Main Loop ──

pub async fn run(state: SharedState) {
    let mut consecutive_not_running: u32 = 0;

    loop {
        if is_mlx_running().await {
            consecutive_not_running = 0;

            let active_model = fetch_active_model().await;
            let display_text = active_model.unwrap_or_else(|| "mlx".to_string());

            state.write().await.mlx_model = Some(display_text);
        } else {
            consecutive_not_running += 1;

            if consecutive_not_running >= NOT_RUNNING_THRESHOLD {
                let mut s = state.write().await;
                if s.mlx_model.is_some() {
                    s.mlx_model = None;
                }
            }
        }

        tokio::time::sleep(POLL_INTERVAL).await;
    }
}

// ── Probe Helpers ──

async fn is_mlx_running() -> bool {
    // mlx_lm.server runs as a python process, so the full command line
    // (not just the binary name) has to be inspected to find it.
    let output = Command::new("ps")
        .env("PATH", crate::utils::full_path())
        .args(["-e", "-o", "args="])
        .output()
        .await;

    if let Ok(out) = output {
        let stdout = String::from_utf8_lossy(&out.stdout);
        stdout.lines().any(|line| line.contains("mlx_lm.server"))
    } else {
        false
    }
}

fn http_client() -> &'static reqwest::Client {
    static CLIENT: OnceLock<reqwest::Client> = OnceLock::new();
    CLIENT.get_or_init(|| {
        reqwest::Client::builder()
            .timeout(REQUEST_TIMEOUT)
            .build()
            .unwrap_or_default()
    })
}

async fn fetch_active_model() -> Option<String> {
    let json: serde_json::Value = http_client()
        .get(API_URL)
        .send()
        .await
        .ok()?
        .json()
        .await
        .ok()?;

    let id = json["data"]
        .as_array()?
        .first()?
        .get("id")?
        .as_str()?
        .to_string();

    // Model ids look like "mlx-community/gpt-oss-20b-MXFP4-Q8";
    // keep only the last path segment before truncating.
    let base: String = id
        .rsplit('/')
        .next()
        .unwrap_or(&id)
        .chars()
        .take(12)
        .collect();

    Some(base)
}


