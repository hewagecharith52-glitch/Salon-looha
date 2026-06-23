$code = Get-Content 'code.html' -Raw

$animationHtml = @"
<!-- Scroll Animation Section -->
<div id="animation-container" style="height: 500vh; position: relative;">
    <div class="sticky-canvas-container" style="position: sticky; top: 0; width: 100%; height: 100vh; overflow: hidden; background-color: #000; z-index: 10;">
        <div class="loading" id="loading" style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); color: white; font-family: sans-serif; font-size: 24px; z-index: 20;">Loading... 0%</div>
        <canvas id="scroll-canvas" style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); width: 100vw; height: 100vh; object-fit: cover;"></canvas>
    </div>
</div>
<!-- End Scroll Animation Section -->
"@

$scriptHtml = @"
<script>
    const canvas = document.getElementById('scroll-canvas');
    const context = canvas.getContext('2d');
    const loading = document.getElementById('loading');

    const frameCount = 173;
    const currentFrame = index => (
        `ezgif-frame-` + (index + 1).toString().padStart(3, '0') + `.jpg`
    );

    const images = [];
    let loadedImages = 0;
    let imagesReady = false;

    canvas.width = 1920;
    canvas.height = 1080;

    for (let i = 0; i < frameCount; i++) {
        const img = new Image();
        img.onload = () => {
            loadedImages++;
            loading.innerText = `Loading... ${Math.round((loadedImages / frameCount) * 100)}%`;
            
            if (loadedImages === 1) {
                canvas.width = img.width;
                canvas.height = img.height;
                context.drawImage(img, 0, 0);
            }

            if (loadedImages === frameCount) {
                loading.style.display = 'none';
                imagesReady = true;
                requestAnimationFrame(() => updateImage());
            }
        };
        img.src = currentFrame(i);
        images.push(img);
    }

    const updateImage = () => {
        if (!imagesReady) return;
        
        const container = document.getElementById('animation-container');
        const rect = container.getBoundingClientRect();
        
        const maxScroll = rect.height - window.innerHeight;
        let scrollFraction = 0;
        
        if (rect.top > 0) {
            scrollFraction = 0;
        } else if (-rect.top >= maxScroll) {
            scrollFraction = 1;
        } else {
            scrollFraction = -rect.top / maxScroll;
        }

        const frameIndex = Math.min(
            frameCount - 1,
            Math.max(0, Math.floor(scrollFraction * frameCount))
        );

        requestAnimationFrame(() => {
            context.drawImage(images[frameIndex], 0, 0);
        });
    };

    window.addEventListener('scroll', () => {
        updateImage();
    });

    window.addEventListener('resize', () => {
        if(imagesReady){
            updateImage();
        }
    });
</script>
</body>
"@

# Replace <main class="pt-20"> with <main class="pt-20"> + animationHtml
$code = $code -replace '<main class="pt-20">', ("<main class=`"pt-20`">`n" + $animationHtml)

# Replace </body> with scriptHtml
$code = $code -replace '</body>', $scriptHtml

Set-Content 'index.html' $code
Write-Host "Done!"
