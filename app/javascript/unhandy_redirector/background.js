// リダイレクト先のURL
// 開発中は 'http://localhost:3000'
// 本番環境にデプロイしたら、そのURLに変更してください (例: 'https://www.unhandy-for-happiness.com')
const redirectUrl = "http://52.68.23.100:3000";
const targetSites = ["youtube.com", "instagram.com"];

// webNavigation APIを使用して、ナビゲーション開始前にURLをチェック
chrome.webNavigation.onBeforeNavigate.addListener((details) => {
  // メインフレーム（トップレベルのナビゲーション）のみを処理
  if (details.frameId !== 0) {
    return;
  }

  const url = details.url;
  
  // URLが存在し、httpまたはhttpsで始まる場合
  if (url && (url.startsWith('http://') || url.startsWith('https://'))) {
    // ターゲットサイトのいずれかを含んでいるかチェック
    const isTargetSite = targetSites.some(site => url.includes(site));

    if (isTargetSite && !url.startsWith(redirectUrl)) {
      // URLに 'allow_access=true' パラメータが含まれている場合はリダイレクトをスキップ
      // これはチェックリスト完了後のYouTubeアクセスを許可するため
      try {
        const urlObj = new URL(url);
        const allowAccess = urlObj.searchParams.get('allow_access') === 'true';

        if (!allowAccess) {
          // 無限ループを防ぎつつ、リダイレクトを実行
          chrome.tabs.update(details.tabId, { url: redirectUrl });
        }
      } catch (e) {
        // URLのパースに失敗した場合もリダイレクト（安全のため）
        chrome.tabs.update(details.tabId, { url: redirectUrl });
      }
    }
  }
}, {
  url: [
    { hostContains: 'youtube.com' },
    { hostContains: 'instagram.com' }
  ]
});