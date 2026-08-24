// API, Routing, and Tab State
let activeRoute = 'email'; // 'email' or 'sms'
let activeDevGramTab = 'feed'; // 'feed' or 'chat'
const consoleLogs = document.getElementById('console-logs');

// Horizontal Stories Database (Includes My Story and dynamic stories)
let devgramStories = [
    { id: "story_1", authorName: "VESPER_NET", authorEmail: "vesper.x@cybernet.io", avatarIndex: 1, imageUrl: "https://picsum.photos/seed/vesperstory/600/1000", timestamp: "2026-06-03T11:00:00Z" },
    { id: "story_2", authorName: "KAELEN_FIXER", authorEmail: "kaelen.net@arasaka.corp", avatarIndex: 2, imageUrl: "https://picsum.photos/seed/kaelenstory/600/1000", timestamp: "2026-06-03T11:30:00Z" }
];

// Initial Mock DevGram Posts Database
let devgramPosts = [
    {
        id: "post_web_1",
        authorName: "VESPER_NET",
        authorEmail: "vesper.x@cybernet.io",
        avatarIndex: 1,
        caption: "Procedurally compiled a new cyberpunk neon skyline! The voxel renderer handles 50k+ nodes now without lagging. #VoxelEngine #Cyberpunk",
        imageUrl: "https://picsum.photos/seed/cyberskyline/600/400",
        likes: ["kaelen.net@arasaka.corp"],
        comments: [
            { author: "KAELEN_FIXER", text: "Sick! What shader techniques did you use for the emissive glow?", timestamp: "2026-06-03T11:45:00Z" },
            { author: "AEGIS_PILOT", text: "The anti-aliasing looks super clean. Excellent work.", timestamp: "2026-06-03T12:10:00Z" }
        ],
        timestamp: "2026-06-03T10:30:00Z"
    },
    {
        id: "post_web_2",
        authorName: "KAELEN_FIXER",
        authorEmail: "kaelen.net@arasaka.corp",
        avatarIndex: 2,
        caption: "Calibrated the suspension and torque parameters on the vehicle physics simulator today. Check out this hill climbing run! #PhysicsEngine #GameDev",
        imageUrl: "https://picsum.photos/seed/physicsrun/600/400",
        likes: ["vesper.x@cybernet.io", "orion.prime@orbit.org"],
        comments: [
            { author: "VESPER_NET", text: "Nice drift! Suspension load distribution looks stable.", timestamp: "2026-06-03T12:05:00Z" }
        ],
        timestamp: "2026-06-03T11:20:00Z"
    },
    {
        id: "post_web_3",
        authorName: "AEGIS_PILOT",
        authorEmail: "aegis9.droid@security.net",
        avatarIndex: 3,
        caption: "Constructed a multiplayer matchmaking sub-layer today. Pings are hitting <15ms on local cluster test scripts. #Netcode #Multiplayer",
        imageUrl: "https://picsum.photos/seed/netcode/600/400",
        likes: ["vesper.x@cybernet.io"],
        comments: [],
        timestamp: "2026-06-03T09:15:00Z"
    }
];

// Connected Operators Directory
const activeOperators = [
    { email: "vesper.x@cybernet.io", name: "VESPER_NET", ping: "18ms", status: "ONLINE", role: "NETRUNNER LEGEND", avatar: 1, bio: "Netrunner legend. Overriding cognitive clusters since seed 0x0A." },
    { email: "kaelen.net@arasaka.corp", name: "KAELEN_FIXER", ping: "32ms", status: "ONLINE", role: "CYBERNETIC FIXER", avatar: 2, bio: "Hardware & logistics compiler. Calibrates vehicle engine models." },
    { email: "aegis9.droid@security.net", name: "AEGIS_PILOT", ping: "25ms", status: "ONLINE", role: "SECURITY ANDROID", avatar: 3, bio: "Security and defense compiler droid. Optimizes edge latency." },
    { email: "orion.prime@orbit.org", name: "ORION_PRIME", ping: "44ms", status: "AWAY", role: "COLONY PIONEER", avatar: 0, bio: "Warp drive explorer and colony navigation pilot." }
];

// Direct Messaging Logs Database
let chatDatabase = {
    "vesper.x@cybernet.io": [
        { sender: "vesper.x@cybernet.io", text: "Yo! Did you check out the new physics simulator features yet?", timestamp: "11:10" },
        { sender: "me", text: "Yeah! The suspension calibration is super detailed. Compiling smooth vectors.", timestamp: "11:12" },
        { sender: "vesper.x@cybernet.io", text: "Excellent. Ping me if you encounter any heap buffer issues on Android.", timestamp: "11:15" }
    ],
    "kaelen.net@arasaka.corp": [
        { sender: "kaelen.net@arasaka.corp", text: "Hey agent, do you need any specific hardware specs for the voxel engine compile?", timestamp: "10:04" },
        { sender: "me", text: "I think we are good. VRAM is holding at 5.4GB.", timestamp: "10:07" }
    ],
    "aegis9.droid@security.net": [],
    "orion.prime@orbit.org": []
};

let activeChatEmail = null;
let activeProfileEmail = null;

// Stories Player Timer
let storyTimer = null;
let storyProgress = 0;

// On Document Ready
document.addEventListener("DOMContentLoaded", () => {
    fetchGameNews();
    renderStories();
    renderFeed();
    renderChatThreads();
    loadWebHUDLayout();
});

/* ==========================================================================
   OTP Dispatch Panel Section
   ========================================================================== */

function selectRoute(route) {
    activeRoute = route;
    document.getElementById('btn-email').classList.toggle('active', route === 'email');
    document.getElementById('btn-sms').classList.toggle('active', route === 'sms');
    
    const recipientInput = document.getElementById('otp-recipient');
    if (route === 'email') {
        recipientInput.placeholder = "e.g. agent@gmail.com";
        if (recipientInput.value.trim() === '' || recipientInput.value.includes('+') || !recipientInput.value.includes('@')) {
            recipientInput.value = "agent.antimatter@gmail.com";
        }
    } else {
        recipientInput.placeholder = "e.g. +15550192834";
        if (recipientInput.value.trim() === '' || recipientInput.value.includes('@')) {
            recipientInput.value = "+15550192834";
        }
    }
    logToConsole(`Route modified. Routing via ${route.toUpperCase()} API channel.`);
}

function logToConsole(message) {
    const time = new Date().toLocaleTimeString();
    consoleLogs.innerHTML += `\n&gt; [${time}] ${message}`;
    consoleLogs.scrollTop = consoleLogs.scrollHeight;
}

function clearConsole() {
    consoleLogs.innerHTML = `&gt; CONSOLE CLEARED. STANDBY.`;
}

async function dispatchOtp() {
    const recipient = document.getElementById('otp-recipient').value.trim();
    if (recipient === "") {
        logToConsole("ERROR: Recipient address/phone cannot be empty.");
        return;
    }

    const code = Math.floor(100000 + Math.random() * 900000).toString();
    
    // Read Credentials
    const twilioSid = document.getElementById('twilio-sid').value.trim();
    const twilioToken = document.getElementById('twilio-token').value.trim();
    const twilioFrom = document.getElementById('twilio-from').value.trim();
    const sendGridKey = document.getElementById('sendgrid-key').value.trim();
    const senderEmail = document.getElementById('sender-email').value.trim();

    logToConsole(`Initializing API payload for destination key (${recipient})...`);

    if (activeRoute === 'email') {
        // SendGrid payload logging
        const emailFrom = senderEmail !== "" ? senderEmail : "noreply@dreamengine.ai";
        const sendgridPayload = {
            personalizations: [{ to: [{ email: recipient }] }],
            from: { email: emailFrom, name: "DreamEngine Security" },
            subject: "DreamEngine AI Secure OTP Code",
            content: [{
                type: "text/plain",
                value: `Your One-Time Passcode (OTP) is: ${code}\n\nEnter this inside the identification terminal to unlock your dossier.`
            }]
        };

        logToConsole(`[SENDGRID PAYLOAD] POST https://api.sendgrid.com/v3/mail/send`);
        logToConsole(JSON.stringify(sendgridPayload, null, 2));

        if (sendGridKey === "") {
            logToConsole(`WARNING: SendGrid API Key omitted. Running HIGH-FIDELITY SIMULATION MODE.`);
            logToConsole(`[FIREBASE OTP] DISPATCHED TO GMAIL: ${recipient}`);
            logToConsole(`[FIREBASE OTP] SECURE 6-DIGIT PASSCODE: ${code}`);
            logToConsole(`STATUS: Simulation complete. Target passcode buffered successfully.`);
        } else {
            logToConsole(`Transmitting HTTP requests to SendGrid servers...`);
            try {
                const response = await fetch("https://api.sendgrid.com/v3/mail/send", {
                    method: 'POST',
                    headers: {
                        "Authorization": `Bearer ${sendGridKey}`,
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify(sendgridPayload)
                });
                
                logToConsole(`[HTTP RESPONSE STATUS] ${response.status} ${response.statusText}`);
                if (response.ok) {
                    logToConsole(`SUCCESS: OTP code sent. Synchronized operator password.`);
                } else {
                    const text = await response.text();
                    logToConsole(`ERROR details: ${text}`);
                }
            } catch (err) {
                logToConsole(`CORS ALERT: Browser client-side calls are restricted by SendGrid CORS policies.`);
                logToConsole(`FALLBACK SIMULATOR DETECTED: Dispatched Mock passcode ${code} to ${recipient}.`);
                logToConsole(`Advice: To run this in production, route these API calls through a secure backend node.`);
            }
        }
    } else {
        // Twilio payload logging
        const cleanPhone = recipient.replace(/[^\d\+]/g, '');
        const twilioPayload = new URLSearchParams();
        twilioPayload.append("To", cleanPhone);
        twilioPayload.append("From", twilioFrom !== "" ? twilioFrom : "+15017122661");
        twilioPayload.append("Body", `Your DreamEngine AI Secure OTP is: ${code}. Please enter it to decrypt operator dossier.`);

        logToConsole(`[TWILIO PAYLOAD] POST https://api.twilio.com/2010-04-01/Accounts/${twilioSid || 'AC_MOCK_SID'}/Messages.json`);
        logToConsole(twilioPayload.toString().replace(/&/g, "\n  &"));

        if (twilioSid === "" || twilioToken === "" || twilioFrom === "") {
            logToConsole(`WARNING: Twilio credentials incomplete. Running HIGH-FIDELITY SIMULATION MODE.`);
            logToConsole(`[FIREBASE OTP] DISPATCHED TO MOBILE: ${recipient}`);
            logToConsole(`[FIREBASE OTP] SECURE 6-DIGIT PASSCODE: ${code}`);
            logToConsole(`STATUS: Simulation complete. Target passcode buffered successfully.`);
        } else {
            logToConsole(`Transmitting HTTP requests to Twilio SMS gateway...`);
            try {
                const authHeader = 'Basic ' + btoa(`${twilioSid}:${twilioToken}`);
                const response = await fetch(`https://api.twilio.com/2010-04-01/Accounts/${twilioSid}/Messages.json`, {
                    method: 'POST',
                    headers: {
                        "Authorization": authHeader,
                        "Content-Type": "application/x-www-form-urlencoded"
                    },
                    body: twilioPayload
                });

                logToConsole(`[HTTP RESPONSE STATUS] ${response.status} ${response.statusText}`);
                if (response.ok) {
                    logToConsole(`SUCCESS: Twilio SMS sent. Synchronized operator password.`);
                } else {
                    const text = await response.text();
                    logToConsole(`ERROR details: ${text}`);
                }
            } catch (err) {
                logToConsole(`CORS ALERT: Browser client-side calls are restricted by Twilio CORS policies.`);
                logToConsole(`FALLBACK SIMULATOR DETECTED: Dispatched Mock SMS passcode ${code} to ${recipient}.`);
                logToConsole(`Advice: To run this in production, route these API calls through a secure backend node.`);
            }
        }
    }
}

/* ==========================================================================
   Games News Wire Section
   ========================================================================== */

const fallbackNews = [
    {
        title: "DreamEngine AI procedurally compiles its first voxel-based racing environment",
        pubDate: "2026-06-03 12:00:00",
        link: "#",
        author: "Vesper_Net",
        thumbnail: "https://picsum.photos/seed/voxelnews/600/400",
        description: "Operators have successfully compiled a fully dynamic driving environment utilizing Stark-HUD physics telemetry and real-time ray-tracing matrix protocols."
    },
    {
        title: "Twitch integrations announced for the multiplayer cyber lobby system",
        pubDate: "2026-06-02 09:30:00",
        link: "#",
        author: "Kaelen_Fixer",
        thumbnail: "https://picsum.photos/seed/lobby/600/400",
        description: "Matchmaking ping profiles drop below 20ms on all US East Coast edge node servers, paving the way for massive virtual operator tournaments."
    },
    {
        title: "Top 10 procedural generation engines shaping the next decade of gaming",
        pubDate: "2026-06-01 15:45:00",
        link: "#",
        author: "Aegis_Pilot",
        thumbnail: "https://picsum.photos/seed/tech/600/400",
        description: "A deep dive into neural voxel compilers, physics sandbox engines, and how AI-driven layout models are replacing traditional level design workflows."
    }
];

async function fetchGameNews() {
    const container = document.getElementById('news-container');
    container.innerHTML = '<div class="loading-spinner"></div>';

    try {
        const response = await fetch("https://api.rss2json.com/v1/api.json?rss_url=https://www.gamespot.com/feeds/news/");
        if (!response.ok) throw new Error("Network status was not OK");
        const data = await response.json();
        
        if (data.status === 'ok' && data.items && data.items.length > 0) {
            renderNews(data.items);
        } else {
            renderNews(fallbackNews);
        }
    } catch (e) {
        console.warn("Gamespot feed failed, loading high-fidelity mock news feed: ", e);
        renderNews(fallbackNews);
    }
}

function renderNews(items) {
    const container = document.getElementById('news-container');
    container.innerHTML = '';

    items.forEach(item => {
        let thumbnail = "";
        if (item.thumbnail && item.thumbnail !== "") {
            thumbnail = item.thumbnail;
        } else if (item.enclosure && item.enclosure.link) {
            thumbnail = item.enclosure.link;
        } else {
            let hash = 0;
            for (let i = 0; i < item.title.length; i++) {
                hash = item.title.charCodeAt(i) + ((hash << 5) - hash);
            }
            thumbnail = `https://picsum.photos/seed/${Math.abs(hash)}/600/400`;
        }

        const cleanDesc = item.description.replace(/<[^>]*>|&nbsp;/g, ' ').trim();
        const shortDesc = cleanDesc.length > 150 ? cleanDesc.substring(0, 147) + "..." : cleanDesc;
        const author = item.author && item.author !== "" ? item.author.toUpperCase() : "STAFF WRITER";
        
        const card = document.createElement('div');
        card.className = 'news-card';
        card.innerHTML = `
            <div class="news-img" style="background-image: url('${thumbnail}')">
                <div class="news-img-overlay"></div>
                <div class="news-date">${item.pubDate}</div>
            </div>
            <div class="news-content">
                <h3>${item.title}</h3>
                <div class="news-meta">&#9997; AGENT: ${author}</div>
                <p class="news-desc">${shortDesc}</p>
                <a href="${item.link}" target="_blank" class="read-more">LAUNCH WIRE</a>
            </div>
        `;
        container.appendChild(card);
    });
}

/* ==========================================================================
   DevGram Social Hub Section
   ========================================================================== */

function switchDevGramTab(tab) {
    activeDevGramTab = tab;
    document.getElementById('tab-feed').classList.toggle('active', tab === 'feed');
    document.getElementById('tab-chat').classList.toggle('active', tab === 'chat');
    document.getElementById('tab-stocks').classList.toggle('active', tab === 'stocks');
    
    document.getElementById('devgram-feed-view').classList.toggle('active', tab === 'feed');
    document.getElementById('devgram-chat-view').classList.toggle('active', tab === 'chat');
    document.getElementById('devgram-stocks-view').classList.toggle('active', tab === 'stocks');

    if (tab === 'stocks') {
        renderWebStocks();
        renderWebGames();
        renderWebHoldings();
        updateWebPortfolioValues();
        fetchWebGameDeals();
    }
}

function renderStories() {
    const container = document.getElementById('stories-container');
    container.innerHTML = '';

    const avatarIcons = [
        '&#127384;', // Core
        '&#128100;', // Net
        '&#129302;', // Drone
        '&#129489;&#128187;' // Pilot
    ];

    // 1. My Story (Upload Story)
    const myItem = document.createElement('div');
    myItem.className = 'story-item';
    myItem.onclick = () => openStoryUploadModal();
    myItem.innerHTML = `
        <div class="story-ring">
            <span class="story-avatar-icon">&#43;</span>
        </div>
        <span class="story-name" style="color: var(--neon-blue);">My Story</span>
    `;
    container.appendChild(myItem);

    // 2. Active Stories
    devgramStories.forEach(story => {
        const item = document.createElement('div');
        item.className = 'story-item';
        item.onclick = () => playStoryViewer(story);
        item.innerHTML = `
            <div class="story-ring active-story">
                <span class="story-avatar-icon">${avatarIcons[story.avatarIndex % avatarIcons.length]}</span>
                <span class="story-status-dot" style="background-color: var(--neon-blue);"></span>
            </div>
            <span class="story-name">${story.authorName}</span>
        `;
        container.appendChild(item);
    });

    // 3. Fallbacks
    activeOperators.forEach(op => {
        const hasStory = devgramStories.some(s => s.authorEmail === op.email);
        if (hasStory || op.email === "operator.antimatter@dreamengine.ai") return;

        const item = document.createElement('div');
        item.className = 'story-item';
        item.onclick = () => {
            const mockStory = {
                authorName: op.name,
                imageUrl: `https://picsum.photos/seed/${op.name}story/600/1000`
            };
            playStoryViewer(mockStory);
        };
        item.innerHTML = `
            <div class="story-ring">
                <span class="story-avatar-icon">${avatarIcons[op.avatar % avatarIcons.length]}</span>
                <span class="story-status-dot"></span>
            </div>
            <span class="story-name" style="opacity:0.6;">${op.name}</span>
        `;
        container.appendChild(item);
    });
}

function renderFeed() {
    const container = document.getElementById('posts-container');
    container.innerHTML = '';

    const avatarIcons = [
        '&#127384;', // Core
        '&#128100;', // Net
        '&#129302;', // Drone
        '&#129489;&#128187;' // Pilot
    ];

    devgramPosts.forEach(post => {
        const commentsHtml = post.comments.map(comm => `
            <div class="post-comment-item">
                <span class="post-comment-author">${comm.author}:</span>
                <span class="post-comment-text">${comm.text}</span>
            </div>
        `).join('');

        const isLiked = post.likes.includes("ANTIMATTER");
        const likeClass = isLiked ? 'post-action-btn liked' : 'post-action-btn';
        const likeText = isLiked ? '&#10084;' : '&#9825;';
        
        const likesLabel = post.likes.length === 0 
            ? "BE THE FIRST TO SIGNAL DISPATCH"
            : post.likes.length === 1
                ? "SIGNALED BY 1 OPERATOR"
                : `SIGNALED BY ${post.likes.length} OPERATORS`;

        const card = document.createElement('div');
        card.className = 'post-card';
        card.id = `post-${post.id}`;
        card.innerHTML = `
            <div class="post-header">
                <div class="post-header-author-box" onclick="showUserProfile('${post.authorEmail}', '${post.authorName}', ${post.avatarIndex})">
                    <div class="post-header-avatar">${avatarIcons[post.avatarIndex % avatarIcons.length]}</div>
                    <div class="post-header-info">
                        <span class="post-author-name">${post.authorName}</span>
                        <div class="post-author-email">${post.authorEmail}</div>
                    </div>
                </div>
                <span class="post-connected-tag">CONNECTED</span>
            </div>
            
            <div class="post-media-container" ondblclick="doubleClickLike('${post.id}')">
                <img class="post-media" src="${post.imageUrl}" alt="Media capture">
                <span class="heart-pop" id="heart-pop-${post.id}">&#10084;</span>
            </div>

            <div class="post-actions">
                <button class="${likeClass}" onclick="toggleLike('${post.id}')" id="like-btn-${post.id}">
                    ${likeText}
                </button>
                <button class="post-action-btn" onclick="focusCommentInput('${post.id}')">
                    &#128172;
                </button>
                <button class="post-action-btn" onclick="sharePost('${post.authorName}')">
                    &#128206;
                </button>
                <div class="post-date">${post.timestamp.split('T')[0]}</div>
            </div>

            <div class="post-likes-count" id="likes-count-${post.id}">${likesLabel}</div>
            
            <div class="post-caption">
                <span class="post-caption-author" onclick="showUserProfile('${post.authorEmail}', '${post.authorName}', ${post.avatarIndex})">${post.authorName}</span>
                <span class="post-caption-text">${post.caption}</span>
            </div>

            <div class="post-comments" id="comments-box-${post.id}">
                ${commentsHtml}
            </div>

            <form class="comment-input-row" onsubmit="submitComment(event, '${post.id}')">
                <input type="text" class="comment-field" placeholder="LOG FEEDBACK SIGNAL..." id="comment-input-${post.id}">
                <button type="submit" class="comment-submit">SEND</button>
            </form>
        `;
        container.appendChild(card);
    });
}

function sharePost(author) {
    logToConsole(`Copying deep-link for agent ${author}'s project screenshot...`);
}

function focusCommentInput(postId) {
    document.getElementById(`comment-input-${postId}`).focus();
}

function toggleLike(postId) {
    const post = devgramPosts.find(p => p.id === postId);
    if (!post) return;

    const email = "ANTIMATTER";
    const idx = post.likes.indexOf(email);
    if (idx >= 0) {
        post.likes.splice(idx, 1);
    } else {
        post.likes.push(email);
    }

    const likeBtn = document.getElementById(`like-btn-${postId}`);
    const likesCount = document.getElementById(`likes-count-${postId}`);
    const isLiked = post.likes.includes(email);
    
    likeBtn.className = isLiked ? 'post-action-btn liked' : 'post-action-btn';
    likeBtn.innerHTML = isLiked ? '&#10084;' : '&#9825;';

    const likesLabel = post.likes.length === 0 
        ? "BE THE FIRST TO SIGNAL DISPATCH"
        : post.likes.length === 1
            ? "SIGNALED BY 1 OPERATOR"
            : `SIGNALED BY ${post.likes.length} OPERATORS`;
    likesCount.innerText = likesLabel;
}

function doubleClickLike(postId) {
    const post = devgramPosts.find(p => p.id === postId);
    if (!post) return;

    if (!post.likes.includes("ANTIMATTER")) {
        toggleLike(postId);
    }

    const heart = document.getElementById(`heart-pop-${postId}`);
    heart.className = 'heart-pop pop';
    setTimeout(() => {
        heart.className = 'heart-pop';
    }, 600);
}

function submitComment(e, postId) {
    e.preventDefault();
    const input = document.getElementById(`comment-input-${postId}`);
    const text = input.value.trim();
    if (text === "") return;

    const post = devgramPosts.find(p => p.id === postId);
    if (!post) return;

    post.comments.push({
        author: "ANTIMATTER",
        text: text,
        timestamp: new Date().toISOString()
    });

    input.value = '';
    
    const commentBox = document.getElementById(`comments-box-${postId}`);
    commentBox.innerHTML = post.comments.map(comm => `
        <div class="post-comment-item">
            <span class="post-comment-author">${comm.author}:</span>
            <span class="post-comment-text">${comm.text}</span>
        </div>
    `).join('');
}

/* ==========================================================================
   Stories Fullscreen Overlay Player
   ========================================================================== */

function playStoryViewer(story) {
    document.getElementById('story-author-name').innerText = story.authorName;
    document.getElementById('story-img').src = story.imageUrl;
    document.getElementById('story-viewer-modal').classList.add('active');

    // Reset progress
    const progress = document.getElementById('story-progress');
    progress.style.width = '0%';
    storyProgress = 0;

    clearInterval(storyTimer);
    storyTimer = setInterval(() => {
        storyProgress += 1;
        progress.style.width = `${storyProgress}%`;
        
        if (storyProgress >= 100) {
            closeStoryViewer();
        }
    }, 40); // 4 seconds total
}

function closeStoryViewer() {
    clearInterval(storyTimer);
    document.getElementById('story-viewer-modal').classList.remove('active');
}

function advanceOrCloseStory() {
    closeStoryViewer();
}

let uploadedStoryImageBlobUrl = "";

function openStoryUploadModal() {
    uploadedStoryImageBlobUrl = "";
    const picker = document.getElementById('story-file-upload');
    if (picker) picker.value = '';
    const container = document.getElementById('story-preview-container');
    if (container) container.style.display = 'none';
    document.getElementById('story-upload-modal').classList.add('active');
}

function closeStoryUploadModal() {
    document.getElementById('story-upload-modal').classList.remove('active');
}

function handleWebStoryImageUpload(event) {
    const file = event.target.files[0];
    if (file) {
        uploadedStoryImageBlobUrl = URL.createObjectURL(file);
        document.getElementById('story-preview-container').style.display = 'block';
        document.getElementById('modal-story-preview').src = uploadedStoryImageBlobUrl;
        logToConsole("SUCCESS: Selected custom story image from device: " + file.name);
    }
}

function previewStoryImageChange() {
    uploadedStoryImageBlobUrl = "";
    document.getElementById('story-preview-container').style.display = 'none';
}

function submitWebStory() {
    let url = document.getElementById('story-img-select').value;
    if (uploadedStoryImageBlobUrl) {
        url = uploadedStoryImageBlobUrl;
    }
    const newStory = {
        id: `story_${Math.floor(Math.random() * 100000)}`,
        authorName: "ANTIMATTER",
        authorEmail: "operator.antimatter@dreamengine.ai",
        avatarIndex: 0,
        imageUrl: url,
        timestamp: new Date().toISOString()
    };

    devgramStories.unshift(newStory);
    renderStories();
    closeStoryUploadModal();
    logToConsole("SUCCESS: Dispatched custom Story compilation to Operator Matrix node.");
}

/* ==========================================================================
   User Profile Explorer
   ========================================================================== */

function showUserProfile(email, fallbackName, fallbackAvatar) {
    activeProfileEmail = email;
    const op = activeOperators.find(o => o.email.toLowerCase() === email.toLowerCase()) || {
        email: email,
        name: fallbackName,
        role: "OPERATOR",
        bio: "Operator dossier synchronized in local memory registry.",
        ping: "15ms",
        avatar: fallbackAvatar
    };

    document.getElementById('profile-name').innerText = op.name;
    document.getElementById('profile-role').innerText = op.role;
    document.getElementById('profile-email').innerText = op.email;
    document.getElementById('profile-bio').innerText = op.bio;
    document.getElementById('profile-ping-val').innerText = op.ping;

    // Connect button state
    const connectBtn = document.getElementById('connect-btn');
    connectBtn.innerText = "DISCONNECT LINK";
    connectBtn.className = "route-btn";

    // Count operator's posts
    const opPosts = devgramPosts.filter(p => p.authorEmail.toLowerCase() === email.toLowerCase());
    document.getElementById('profile-posts-count').innerText = opPosts.length.toString();

    // Populate post grid thumbnails
    const grid = document.getElementById('profile-posts-grid-container');
    grid.innerHTML = '';

    if (opPosts.length === 0) {
        grid.innerHTML = '<div style="grid-column: span 3; text-align:center; font-size: 10px; color: var(--text-muted); padding:20px;">NO HUD CAPTURES DETECTED</div>';
    } else {
        opPosts.forEach(post => {
            const thumb = document.createElement('div');
            thumb.className = 'grid-thumb';
            thumb.style.backgroundImage = `url('${post.imageUrl}')`;
            thumb.onclick = () => {
                closeUserProfileModal();
                const element = document.getElementById(`post-${post.id}`);
                if (element) element.scrollIntoView({ behavior: 'smooth' });
            };
            grid.appendChild(thumb);
        });
    }

    document.getElementById('user-profile-modal').classList.add('active');
}

function closeUserProfileModal() {
    document.getElementById('user-profile-modal').classList.remove('active');
}

function toggleWebConnection() {
    const btn = document.getElementById('connect-btn');
    const connectionsVal = document.getElementById('profile-connections-val');
    if (btn.innerText.includes("DISCONNECT")) {
        btn.innerText = "ESTABLISH LINK";
        btn.className = "submit-btn";
        connectionsVal.innerText = "323";
        logToConsole(`Connection terminated with agent (${activeProfileEmail}).`);
    } else {
        btn.innerText = "DISCONNECT LINK";
        btn.className = "route-btn";
        connectionsVal.innerText = "324";
        logToConsole(`Connection established with agent (${activeProfileEmail}).`);
    }
}

function openWebChatFromProfile() {
    closeUserProfileModal();
    switchDevGramTab('chat');
    selectChatThread(activeProfileEmail);
}

/* ==========================================================================
   DevChat Direct Messaging
   ========================================================================== */

function renderChatThreads() {
    const container = document.getElementById('chat-sidebar-threads');
    container.innerHTML = '';

    activeOperators.forEach(op => {
        if (op.email === "operator.antimatter@dreamengine.ai") return;
        
        const history = chatDatabase[op.email] || [];
        const isOnline = op.status === 'ONLINE';
        const lastMsg = history.length > 0 ? history[history.length - 1].text : "No messages yet.";
        const isSelected = activeChatEmail === op.email;
        const threadClass = isSelected ? 'chat-sidebar-thread active' : 'chat-sidebar-thread';

        const thread = document.createElement('div');
        thread.className = threadClass;
        thread.onclick = () => selectChatThread(op.email);
        thread.innerHTML = `
            <div class="chat-thread-avatar">${op.name[0]}</div>
            <div class="chat-thread-name">${op.name}</div>
        `;
        container.appendChild(thread);
    });
}

function selectChatThread(email) {
    activeChatEmail = email;
    renderChatThreads();

    const op = activeOperators.find(o => o.email === email);
    const headerInfo = document.getElementById('chat-header-info');
    headerInfo.innerHTML = `
        <span>AGENT: ${op.name} // ${op.role}</span>
        <span class="chat-typing-status" id="chat-typing-text" style="display:none;">TYPING...</span>
    `;

    // Enable Footer
    document.getElementById('chat-send-input').disabled = false;
    document.getElementById('chat-send-btn').disabled = false;

    renderChatMessages();
}

function renderChatMessages() {
    const threadBody = document.getElementById('chat-msg-thread');
    threadBody.innerHTML = '';

    const history = chatDatabase[activeChatEmail] || [];
    if (history.length === 0) {
        threadBody.innerHTML = '<div class="empty-chat-msg">NO MESSAGES IN CHANNEL. SEND A LOG SIGNAL.</div>';
        return;
    }

    history.forEach(msg => {
        const bubble = document.createElement('div');
        const isMe = msg.sender === 'me';
        bubble.className = isMe ? 'chat-message-bubble me' : 'chat-message-bubble other';
        bubble.innerText = msg.text;
        threadBody.appendChild(bubble);
    });

    threadBody.scrollTop = threadBody.scrollHeight;
}

function sendWebChatMessage(e) {
    e.preventDefault();
    const input = document.getElementById('chat-send-input');
    const text = input.value.trim();
    if (text === "" || !activeChatEmail) return;

    // Send my message
    chatDatabase[activeChatEmail].push({
        sender: 'me',
        text: text,
        timestamp: new Date().toLocaleTimeString().substring(0, 5)
    });

    input.value = '';
    renderChatMessages();
    logToConsole(`Direct message transmitted to ${activeChatEmail}`);

    // Trigger mock response
    triggerWebMockReply(activeChatEmail, text);
}

function triggerWebMockReply(otherEmail, userMsg) {
    const typingIndicator = document.getElementById('chat-typing-text');
    if (typingIndicator) typingIndicator.style.display = 'inline';

    const cleanMsg = userMsg.toLowerCase();
    let replyText = "Compilation logs synced successfully. Operations stable.";

    if (cleanMsg.includes("hello") || cleanMsg.includes("hi") || cleanMsg.includes("hey")) {
        replyText = "Greetings operator. Connection verified. What seed values are you compiling?";
    } else if (cleanMsg.includes("physics") || cleanMsg.includes("racing") || cleanMsg.includes("drift")) {
        replyText = "The vehicle torque engine parameters look solid. Ensure you load chassis weight buffers.";
    } else if (cleanMsg.includes("voxel") || cleanMsg.includes("render") || cleanMsg.includes("shader")) {
        replyText = "The shader emissive nodes look gorgeous. Let's sync the voxel code grid.";
    } else if (cleanMsg.includes("ping") || cleanMsg.includes("multiplayer") || cleanMsg.includes("lobby")) {
        replyText = "US-EAST cluster latency check looks stable. I'm ready to host the lobby.";
    }

    setTimeout(() => {
        if (typingIndicator) typingIndicator.style.display = 'none';

        if (!chatDatabase[otherEmail]) chatDatabase[otherEmail] = [];
        chatDatabase[otherEmail].push({
            sender: otherEmail,
            text: replyText,
            timestamp: new Date().toLocaleTimeString().substring(0, 5)
        });

        if (activeChatEmail === otherEmail) {
            renderChatMessages();
        }
        
        logToConsole(`Signal response received from agent ${otherEmail.split('@')[0].toUpperCase()}`);
    }, 1800);
}

/* ==========================================================================
   Modals Previews
   ========================================================================== */

let uploadedPostImageBlobUrl = "";

function openCreatePostModal() {
    uploadedPostImageBlobUrl = "";
    const picker = document.getElementById('post-file-upload');
    if (picker) picker.value = '';
    previewImageChange();
    document.getElementById('create-post-modal').classList.add('active');
}

function closeCreatePostModal() {
    document.getElementById('create-post-modal').classList.remove('active');
}

function handleWebPostImageUpload(event) {
    const file = event.target.files[0];
    if (file) {
        uploadedPostImageBlobUrl = URL.createObjectURL(file);
        document.getElementById('modal-img-preview').src = uploadedPostImageBlobUrl;
        logToConsole("SUCCESS: Selected custom post image from device: " + file.name);
    }
}

function previewImageChange() {
    const sel = document.getElementById('post-img');
    const preview = document.getElementById('modal-img-preview');
    uploadedPostImageBlobUrl = "";
    preview.src = sel.value;
}

function submitPost() {
    const author = document.getElementById('post-author').value.trim();
    let imageUrl = document.getElementById('post-img').value;
    if (uploadedPostImageBlobUrl) {
        imageUrl = uploadedPostImageBlobUrl;
    }
    const caption = document.getElementById('post-caption').value.trim();

    if (author === "" || caption === "") {
        alert("Agent credentials and Caption cannot be empty.");
        return;
    }

    const newPost = {
        id: `post_web_${Math.floor(Math.random() * 100000)}`,
        authorName: author.toUpperCase(),
        authorEmail: `${author.toLowerCase().replace(/\s/g, '')}@dreamengine.ai`,
        avatarIndex: 0,
        imageUrl: imageUrl,
        likes: [],
        comments: [],
        timestamp: new Date().toISOString()
    };

    devgramPosts.unshift(newPost);
    renderFeed();
    closeCreatePostModal();
    logToConsole(`SUCCESS: Broadcasted custom pipeline capture from agent ${author.toUpperCase()} to DevGram feed.`);
    document.getElementById('post-caption').value = '';
}

// --- Game Stocks & Store databases ---
let webCredits = 10000.00;
let webHoldings = {}; // Symbol -> shares
let selectedTradeSymbol = null;
let webStocks = [
    { symbol: "VESP", name: "Vesper Interactive", currentPrice: 120.00, changePercent: 0.0, priceHistory: [118, 121, 119, 122, 120], sector: "Voxel Engines" },
    { symbol: "KFIX", name: "Kaelen Fixer Games", currentPrice: 85.50, changePercent: 0.0, priceHistory: [88, 86, 84, 87, 85.5], sector: "Physics Sandboxes" },
    { symbol: "ASDR", name: "Aegis Security Droid", currentPrice: 195.00, changePercent: 0.0, priceHistory: [192, 196, 193, 194, 195], sector: "AI & Netcode" },
    { symbol: "ORIP", name: "Orion Pioneer Systems", currentPrice: 42.00, changePercent: 0.0, priceHistory: [44, 43, 41, 40, 42], sector: "Warp Simulators" },
    { symbol: "DRME", name: "DreamEngine Corp", currentPrice: 310.00, changePercent: 0.0, priceHistory: [305, 308, 307, 312, 310], sector: "Procedural Generative Core" }
];
let webGames = [
    { title: "Voxel Strike: Overdrive", description: "Engage rogue security systems in endless procedurally generated neon streets.", price: 39.99, genre: "Cyberpunk Shooter", imageUrl: "https://picsum.photos/seed/voxelstrike/600/400", isOwned: false },
    { title: "Cyber Drift 2099", description: "Frictionless drift calibration simulator featuring raw telemetry feedback.", price: 29.99, genre: "Physics Racer", imageUrl: "https://picsum.photos/seed/cyberdrift/600/400", isOwned: false },
    { title: "Netrunner Chronicles", description: "Decouple buffer systems and crack security cores on the lower-level highway.", price: 19.99, genre: "Hacking RPG", imageUrl: "https://picsum.photos/seed/chronicles/600/400", isOwned: false },
    { title: "Colony Pioneer VR", description: "Calculate warp coordinates and navigate asteroid zones in full physics.", price: 49.99, genre: "Space Sandbox", imageUrl: "https://picsum.photos/seed/colonyvr/600/400", isOwned: false },
    { title: "Dream Arena Alpha", description: "Procedural action framework designed directly by AI compiler.", price: 0.00, genre: "Procedural Action", imageUrl: "https://picsum.photos/seed/dreamarena/600/400", isOwned: true }
];

// Initialize Web Stock timer
setInterval(() => {
    tickWebStockMarket();
}, 6000);

function tickWebStockMarket() {
    webStocks.forEach(stock => {
        let percentChange = (Math.random() * 8.0) - 4.0; // -4.0% to +4.0%
        if (stock.symbol === 'DRME' && Math.random() < 0.6) {
            percentChange += 1.0;
        }
        let oldPrice = stock.currentPrice;
        let changeAmount = oldPrice * (percentChange / 100.0);
        stock.currentPrice = Math.max(1.0, oldPrice + changeAmount);
        stock.changePercent = percentChange;
        
        stock.priceHistory.push(stock.currentPrice);
        if (stock.priceHistory.length > 15) {
            stock.priceHistory.shift();
        }
    });

    // Random News Logs
    if (Math.random() < 0.35) {
        const events = [
            "DRME launches voxel pathfinder upgrade, stock climbs.",
            "KFIX delays cyberpunk physics patch, minor stock drop.",
            "VESP reports server grid overload, network stability warning.",
            "ASDR secures defense drone net contract, shares jump.",
            "ORIP signs orbital explorer agreement, trading volume expands.",
            "Market analysts upgrade DRME target index to bullish.",
            "Security warning on sector 4 nets drops hacker sentiment slightly."
        ];
        const event = events[Math.floor(Math.random() * events.length)];
        logToConsole(`[STOCKS NEWS] ${event}`);
    }

    if (activeDevGramTab === 'stocks') {
        renderWebStocks();
        updateWebPortfolioValues();
    }
}

function getWebPortfolioValue() {
    let stocksValue = 0;
    Object.keys(webHoldings).forEach(symbol => {
        const stock = webStocks.find(s => s.symbol === symbol);
        if (stock) {
            stocksValue += stock.currentPrice * webHoldings[symbol];
        }
    });
    return webCredits + stocksValue;
}

function updateWebPortfolioValues() {
    const portfolioValEl = document.getElementById('web-portfolio-val');
    const creditsValEl = document.getElementById('web-credits-val');
    if (portfolioValEl) portfolioValEl.innerText = `$${getWebPortfolioValue().toFixed(2)}`;
    if (creditsValEl) creditsValEl.innerText = `$${webCredits.toFixed(2)}`;
}

function renderWebHoldings() {
    const list = document.getElementById('web-holdings-list');
    if (!list) return;
    list.innerHTML = '';
    const keys = Object.keys(webHoldings);
    
    if (keys.length === 0) {
        list.innerHTML = '<div class="empty-holdings">NO SHARE ASSETS OWNED</div>';
        return;
    }

    keys.forEach(symbol => {
        const qty = webHoldings[symbol];
        const stock = webStocks.find(s => s.symbol === symbol);
        const value = stock ? stock.currentPrice * qty : 0;
        const badge = document.createElement('div');
        badge.className = 'holding-badge';
        badge.innerText = `${symbol} x${qty} ($${value.toFixed(2)})`;
        list.appendChild(badge);
    });
}

function renderWebStocks() {
    const container = document.getElementById('web-stocks-list');
    if (!container) return;
    container.innerHTML = '';

    webStocks.forEach(stock => {
        const isPositive = stock.changePercent >= 0;
        const trendClass = isPositive ? 'trend-up' : 'trend-down';
        const trendSign = isPositive ? '+' : '';
        const row = document.createElement('div');
        row.className = 'stock-ticker-row';
        row.innerHTML = `
            <div class="stock-info">
                <h4>${stock.symbol} <span>// ${stock.sector}</span></h4>
                <p>${stock.name}</p>
            </div>
            <div class="stock-sparkline">
                <canvas id="canvas-${stock.symbol}" width="80" height="28"></canvas>
            </div>
            <div class="stock-price-box">
                <span class="stock-price-val">$${stock.currentPrice.toFixed(2)}</span>
                <span class="stock-change-percent ${trendClass}">${trendSign}${stock.changePercent.toFixed(2)}%</span>
            </div>
            <button class="stock-trade-btn" onclick="selectWebTradeStock('${stock.symbol}')">TRADE</button>
        `;
        container.appendChild(row);
        drawWebSparkline(stock.symbol, stock.priceHistory, isPositive);
    });
}

function drawWebSparkline(symbol, history, isPositive) {
    const canvas = document.getElementById(`canvas-${symbol}`);
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    if (history.length < 2) return;
    
    ctx.strokeStyle = isPositive ? "#00FF88" : "#FF1E27";
    ctx.lineWidth = 1.5;
    ctx.lineCap = "round";

    const maxVal = Math.max(...history);
    const minVal = Math.min(...history);
    let valRange = maxVal - minVal;
    if (valRange === 0) valRange = 1.0;

    const stepX = canvas.width / (history.length - 1);
    ctx.beginPath();

    for (let i = 0; i < history.length; i++) {
        const x = i * stepX;
        const normalizedY = (history[i] - minVal) / valRange;
        const y = canvas.height - (normalizedY * (canvas.height - 4) + 2);
        
        if (i === 0) {
            ctx.moveTo(x, y);
        } else {
            ctx.lineTo(x, y);
        }
    }
    
    ctx.stroke();
}

function selectWebTradeStock(symbol) {
    selectedTradeSymbol = symbol;
    const panel = document.getElementById('web-trade-panel');
    if (panel) panel.style.display = 'block';
    const titleEl = document.getElementById('trade-panel-title');
    if (titleEl) titleEl.innerText = `TRADE SECURITY: ${symbol}`;
}

function executeWebTrade(type) {
    if (!selectedTradeSymbol) return;
    const stock = webStocks.find(s => s.symbol === selectedTradeSymbol);
    if (!stock) return;

    const qty = parseInt(document.getElementById('trade-qty').value) || 0;
    if (qty <= 0) {
        alert("Enter a valid shares quantity.");
        return;
    }

    if (type === 'buy') {
        const cost = stock.currentPrice * qty;
        if (webCredits >= cost) {
            webCredits -= cost;
            webHoldings[selectedTradeSymbol] = (webHoldings[selectedTradeSymbol] || 0) + qty;
            logToConsole(`[TRADE] BOUGHT ${qty} SHARES OF ${selectedTradeSymbol} FOR $${cost.toFixed(2)}`);
        } else {
            alert("Insufficient available cash credits.");
        }
    } else {
        const currentShares = webHoldings[selectedTradeSymbol] || 0;
        if (currentShares >= qty) {
            const earnings = stock.currentPrice * qty;
            webCredits += earnings;
            webHoldings[selectedTradeSymbol] = currentShares - qty;
            if (webHoldings[selectedTradeSymbol] === 0) {
                delete webHoldings[selectedTradeSymbol];
            }
            logToConsole(`[TRADE] SOLD ${qty} SHARES OF ${selectedTradeSymbol} FOR $${earnings.toFixed(2)}`);
        } else {
            alert("Insufficient shares owned to execute sale.");
        }
    }

    updateWebPortfolioValues();
    renderWebHoldings();
}

function renderWebGames() {
    const container = document.getElementById('web-games-list');
    if (!container) return;
    container.innerHTML = '';

    webGames.forEach(game => {
        const item = document.createElement('div');
        item.className = 'game-store-item';
        const priceLabel = game.price === 0 ? "GRATIS" : `$${game.price.toFixed(2)}`;
        const actionBtn = game.isOwned 
            ? `<button class="game-buy-btn owned" onclick="launchWebGame('${game.title}')">LAUNCH GAME</button>`
            : `<button class="game-buy-btn" onclick="purchaseWebGame('${game.title}')">BUY LICENSE</button>`;

        item.innerHTML = `
            <img src="${game.imageUrl}" class="game-cover-thumb" alt="Cover">
            <div class="game-store-info">
                <div class="game-store-header-row">
                    <h4>${game.title.toUpperCase()}</h4>
                    <span class="game-genre-tag">${game.genre.toUpperCase()}</span>
                </div>
                <p>${game.description}</p>
                <div class="game-store-footer-row">
                    <span class="game-price-lbl">${priceLabel}</span>
                    ${actionBtn}
                </div>
            </div>
        `;
        container.appendChild(item);
    });
}

function purchaseWebGame(title) {
    const game = webGames.find(g => g.title === title);
    if (!game) return;
    if (webCredits >= game.price) {
        webCredits -= game.price;
        game.isOwned = true;
        logToConsole(`[STORE] ACQUIRED SECURE LICENSE: ${title.toUpperCase()} FOR $${game.price.toFixed(2)}`);
        renderWebGames();
        updateWebPortfolioValues();
    } else {
        alert("Insufficient credits to purchase license. Trade studio stocks to build liquidity.");
    }
}

function launchWebGame(title) {
    logToConsole(`LAUNCH WIRE: Transmitting instruction compiler for game: ${title.toUpperCase()}...`);
    alert(`LAUNCHING ENGINE COMPILATION CORE FOR: ${title.toUpperCase()}!`);
}

/* ==========================================================================
   Customizable HUD & Drag-and-Drop Handlers
   ========================================================================== */

let webCustomizeMode = false;
let draggedElement = null;

// Toggle Customize HUD Mode
function toggleWebCustomizeHUD() {
    webCustomizeMode = !webCustomizeMode;
    const container = document.getElementById('main-dashboard-grid');
    const toggleBtn = document.getElementById('btn-customize-hud');
    const resetBtn = document.getElementById('btn-reset-hud');
    
    if (webCustomizeMode) {
        container.classList.add('customizing-hud');
        toggleBtn.innerText = "SAVE HUD CONFIG";
        toggleBtn.classList.add('active');
        if (resetBtn) resetBtn.style.display = 'inline-block';
        logToConsole("HUD CONFIGURATION ACTIVE. Drag modules to customize layout.");
    } else {
        container.classList.remove('customizing-hud');
        toggleBtn.innerText = "CUSTOMIZE HUD";
        toggleBtn.classList.remove('active');
        if (resetBtn) resetBtn.style.display = 'none';
        
        // Save layout configuration
        saveWebHUDLayout();
        logToConsole("HUD CONFIGURATION SAVED AND COMPILED.");
    }
    
    // Enable or disable draggable behavior for panel sections
    const panels = document.querySelectorAll('.draggable-hud-panel');
    panels.forEach(panel => {
        panel.setAttribute('draggable', webCustomizeMode ? 'true' : 'false');
    });
}

// Reset HUD layout to factory default
function resetWebCustomizeHUD() {
    const colLeft = document.getElementById('col-left');
    const colRight = document.getElementById('col-right');
    const otp = document.getElementById('otp-section');
    const news = document.getElementById('news-section');
    const devgram = document.getElementById('devgram-section');
    
    if (colLeft && colRight && otp && news && devgram) {
        colLeft.appendChild(otp);
        colLeft.appendChild(news);
        colRight.appendChild(devgram);
    }
    
    localStorage.removeItem('dreamengine_hud_layout');
    logToConsole("HUD LAYOUT RESET TO FACTORY DEFAULTS.");
    
    if (webCustomizeMode) {
        toggleWebCustomizeHUD();
    }
}

// Save HUD layout order to localStorage
function saveWebHUDLayout() {
    const colLeft = document.getElementById('col-left');
    const colRight = document.getElementById('col-right');
    if (!colLeft || !colRight) return;
    
    const leftIds = Array.from(colLeft.querySelectorAll('.draggable-hud-panel')).map(el => el.id);
    const rightIds = Array.from(colRight.querySelectorAll('.draggable-hud-panel')).map(el => el.id);
    
    localStorage.setItem('dreamengine_hud_layout', JSON.stringify({
        left: leftIds,
        right: rightIds
    }));
}

// Load HUD layout order from localStorage
function loadWebHUDLayout() {
    const saved = localStorage.getItem('dreamengine_hud_layout');
    if (saved) {
        try {
            const layout = JSON.parse(saved);
            const colLeft = document.getElementById('col-left');
            const colRight = document.getElementById('col-right');
            if (colLeft && colRight) {
                if (layout.left) {
                    layout.left.forEach(id => {
                        const el = document.getElementById(id);
                        if (el) colLeft.appendChild(el);
                    });
                }
                if (layout.right) {
                    layout.right.forEach(id => {
                        const el = document.getElementById(id);
                        if (el) colRight.appendChild(el);
                    });
                }
            }
        } catch (e) {
            console.error("Failed to load saved HUD layout: ", e);
        }
    }
}

// Drag & Drop HTML5 APIs
function handleWebDragStart(event) {
    if (!webCustomizeMode) {
        event.preventDefault();
        return;
    }
    draggedElement = event.currentTarget;
    event.currentTarget.classList.add('dragging');
    event.dataTransfer.setData("text/plain", event.currentTarget.id);
    event.dataTransfer.effectAllowed = "move";
}

// Handle dragging end
function handleWebDragEnd(event) {
    event.currentTarget.classList.remove('dragging');
    draggedElement = null;
    
    // Clear drag-over state on all columns
    const columns = document.querySelectorAll('.grid-col');
    columns.forEach(col => col.classList.remove('drag-over'));
}

// Allow dropping by preventing default
function allowWebDrop(event) {
    if (!webCustomizeMode) return;
    event.preventDefault();
    
    const col = event.currentTarget;
    if (col && col.classList.contains('grid-col')) {
        col.classList.add('drag-over');
    }
}

// Handle drag leave to remove styling
function handleWebDragLeave(event) {
    const col = event.currentTarget;
    if (col && col.classList.contains('grid-col')) {
        col.classList.remove('drag-over');
    }
}

// Handle the drop event
function handleWebDrop(event, columnType) {
    if (!webCustomizeMode) return;
    event.preventDefault();
    
    const col = event.currentTarget;
    if (col) {
        col.classList.remove('drag-over');
    }
    
    const id = event.dataTransfer.getData("text/plain");
    const draggedEl = document.getElementById(id) || draggedElement;
    if (!draggedEl) return;
    
    const afterElement = getDragAfterElement(col, event.clientY);
    if (afterElement) {
        col.insertBefore(draggedEl, afterElement);
    } else {
        col.appendChild(draggedEl);
    }
}

// Find the insertion point in the list
function getDragAfterElement(container, y) {
    const draggableElements = [...container.querySelectorAll('.draggable-hud-panel:not(.dragging)')];
    
    return draggableElements.reduce((closest, child) => {
        const box = child.getBoundingClientRect();
        const offset = y - box.top - box.height / 2;
        if (offset < 0 && offset > closest.offset) {
            return { offset: offset, element: child };
        } else {
            return closest;
        }
    }, { offset: Number.NEGATIVE_INFINITY }).element;
}

/* ==========================================================================
   Real-Time Steam & Epic Deals Client-side Integrations
   ========================================================================== */

let webDeals = [];
let isFetchingWebDeals = false;

const fallbackWebDeals = [
  { title: "Borderlands 3: Super Deluxe Edition", dealID: "mock_web_deal_1", storeID: "28", salePrice: 7.99, normalPrice: 79.99, savingsPercent: 90.0, thumbnail: "https://picsum.photos/seed/borderlands/120/60" },
  { title: "XCOM 2", dealID: "mock_web_deal_2", storeID: "1", salePrice: 5.99, normalPrice: 59.99, savingsPercent: 90.0, thumbnail: "https://picsum.photos/seed/xcom2/120/60" },
  { title: "Portal 2", dealID: "mock_web_deal_3", storeID: "1", salePrice: 0.99, normalPrice: 9.99, savingsPercent: 90.0, thumbnail: "https://picsum.photos/seed/portal2/120/60" }
];

async function fetchWebGameDeals() {
    if (isFetchingWebDeals) return;
    isFetchingWebDeals = true;
    
    const container = document.getElementById('web-deals-list');
    if (container && webDeals.length === 0) {
        container.innerHTML = '<div class="loading-spinner"></div>';
    }

    try {
        const response = await fetch("https://www.cheapshark.com/api/1.0/deals?storeID=1,28&sortBy=Savings&onSale=1&pageSize=30");
        if (!response.ok) throw new Error("Deals query response not OK");
        const data = await response.json();
        
        let parsed = [];
        data.forEach(item => {
            const savings = parseFloat(item.savings || "0");
            if (savings >= 90.0) {
                parsed.push({
                    title: item.title,
                    dealID: item.dealID,
                    storeID: item.storeID,
                    salePrice: parseFloat(item.salePrice || "0"),
                    normalPrice: parseFloat(item.normalPrice || "0"),
                    savingsPercent: savings,
                    thumbnail: item.thumb || `https://picsum.photos/seed/${item.title}/120/60`
                });
            }
        });

        // Fallback to 80% if no 90% discount deals exist currently
        if (parsed.length === 0) {
            data.forEach(item => {
                const savings = parseFloat(item.savings || "0");
                if (savings >= 80.0) {
                    parsed.push({
                        title: item.title,
                        dealID: item.dealID,
                        storeID: item.storeID,
                        salePrice: parseFloat(item.salePrice || "0"),
                        normalPrice: parseFloat(item.normalPrice || "0"),
                        savingsPercent: savings,
                        thumbnail: item.thumb || `https://picsum.photos/seed/${item.title}/120/60`
                    });
                }
            });
        }

        webDeals = parsed.length > 0 ? parsed : fallbackWebDeals;
    } catch (e) {
        console.warn("CheapShark Deals API query failed, loading mock deal buffers: ", e);
        webDeals = fallbackWebDeals;
    } finally {
        isFetchingWebDeals = false;
        renderWebDeals();
    }
}

function renderWebDeals() {
    const container = document.getElementById('web-deals-list');
    if (!container) return;
    container.innerHTML = '';

    if (webDeals.length === 0) {
        container.innerHTML = '<div class="empty-holdings" style="text-align:center; padding: 20px;">NO HIGH VALUE DEALS BUFFERED</div>';
        return;
    }

    webDeals.forEach(deal => {
        const item = document.createElement('div');
        item.className = 'game-store-item';
        const isSteam = deal.storeID === "1";
        const savings = Math.round(deal.savingsPercent);
        
        item.innerHTML = `
            <img src="${deal.thumbnail}" class="game-cover-thumb" style="width: 100px; height: 50px; object-fit: cover;" alt="Cover">
            <div class="game-store-info">
                <div class="game-store-header-row">
                    <h4 style="font-size: 10.5px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 140px;">${deal.title.toUpperCase()}</h4>
                    <span class="game-genre-tag" style="border-color: ${isSteam ? '#00c3ff' : '#ffd000'}; color: ${isSteam ? '#00c3ff' : '#ffd000'}; background: rgba(255, 255, 255, 0.02)">
                        ${isSteam ? 'STEAM' : 'EPIC GAMES'}
                    </span>
                </div>
                <div class="game-store-footer-row" style="margin-top: 8px;">
                    <div style="display: flex; align-items: center;">
                        <span class="deal-normal-price">$${deal.normalPrice.toFixed(2)}</span>
                        <span class="game-price-lbl" style="font-size: 11px;">$${deal.salePrice.toFixed(2)}</span>
                        <span class="deal-saving-badge" style="margin-left: 8px;">-${savings}%</span>
                    </div>
                    <button class="game-buy-btn" onclick="window.open('https://www.cheapshark.com/redirect?dealID=${deal.dealID}', '_blank')">CLAIM DEAL</button>
                </div>
            </div>
        `;
        container.appendChild(item);
    });
}

window.loginTimeouts = [];

function attemptWebLogin() {
    if (window.loginTimeouts) {
        window.loginTimeouts.forEach(clearTimeout);
        window.loginTimeouts = [];
    }

    const emailInput = document.getElementById('login-username').value.trim();
    const passcode = document.getElementById('login-password').value.trim();
    const consoleOutput = document.getElementById('login-console-output');
    const submitBtn = document.getElementById('login-submit-btn');

    if (!emailInput) {
        consoleOutput.innerHTML = `> ERROR: OPERATOR IDENTITY SIGNATURE REQUIRED.<br>> ACCESS LEVEL: REFUSED.`;
        consoleOutput.style.color = '#FF1E27';
        return;
    }

    const emailRegex = /^[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?$/;
    if (!emailRegex.test(emailInput)) {
        consoleOutput.innerHTML = `> ERROR: INVALID IDENTITY SIGNATURE FORMAT.<br>> ACCESS LEVEL: REFUSED.`;
        consoleOutput.style.color = '#FF1E27';
        return;
    }

    if (!passcode) {
        consoleOutput.innerHTML = `> ERROR: PASSCODE REQUIRED.<br>> ACCESS LEVEL: REFUSED.`;
        consoleOutput.style.color = '#FF1E27';
        return;
    }

    if (passcode !== 'DREAM-SECURE-2026') {
        consoleOutput.innerHTML = `> ERROR: DECRYPTION PASSCODE MISMATCH.<br>> SYSTEM INTRUSION DETECTED. COGNITIVE LOCKOUT ACTIVE.`;
        consoleOutput.style.color = '#FF1E27';
        return;
    }

    // Success login sequence
    submitBtn.disabled = true;
    submitBtn.innerText = "LINKING COGNITIVE GATEWAY...";
    consoleOutput.style.color = '#00FF88';
    consoleOutput.innerHTML = `> DECRYPTING ENCRYPTED NODE CHANNELS... 12%`;

    window.loginTimeouts.push(setTimeout(() => {
        consoleOutput.innerHTML = `> DECRYPTING ENCRYPTED NODE CHANNELS... 48%<br>> VERIFYING ACCESS CREDENTIALS: VALID.`;
    }, 200));

    window.loginTimeouts.push(setTimeout(() => {
        consoleOutput.innerHTML = `> DECRYPTING ENCRYPTED NODE CHANNELS... 87%<br>> VERIFYING ACCESS CREDENTIALS: VALID.<br>> ESTABLISHING MESH LINK LAYER...`;
    }, 400));

    window.loginTimeouts.push(setTimeout(() => {
        consoleOutput.innerHTML = `> DECRYPTING ENCRYPTED NODE CHANNELS... 100%<br>> LINK STABILIZED.<br>> INITIALIZING HUD DASHBOARD CORE...`;
    }, 600));

    window.loginTimeouts.push(setTimeout(() => {
        const overlay = document.getElementById('login-overlay');
        overlay.classList.add('hidden');
        logToConsole(`SUCCESSFUL OPERATOR DECRYPT: ACCESS GRANTED TO ${emailInput.toUpperCase()}`);
    }, 850));
}

