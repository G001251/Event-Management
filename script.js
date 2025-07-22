document.addEventListener('DOMContentLoaded', () => {
    // --- State Management ---
    const designData = {
        eventType: '',
        dimensions: {},
        extras: [],
        styles: []
    };

    // --- DOM Selections ---
    const pages = document.querySelectorAll('.page');
    const backButtons = document.querySelectorAll('.back-button');

    const homeForm = document.getElementById('event-type-form');
    const dimensionsForm = document.getElementById('dimensions-form');
    const styleForm = document.getElementById('style-form');

    const loadingSpinner = document.getElementById('loading-spinner');
    const generatedImage = document.getElementById('generated-image');
    const errorContainer = document.getElementById('error-message');
    const retryButton = document.getElementById('retry-button');
    const ctaFooter = document.querySelector('.cta-footer');

    // --- Navigation ---
    function navigateTo(pageId) {
        pages.forEach(page => {
            page.classList.remove('active');
            if (page.dataset.page === pageId) {
                page.classList.add('active');
            }
        });
        window.scrollTo(0, 0);
    }

    backButtons.forEach(button => {
        button.addEventListener('click', () => {
            navigateTo(button.dataset.target);
        });
    });

    // --- Page 1: Home/Selection Logic ---
    homeForm.addEventListener('submit', (e) => {
        e.preventDefault();
        const eventTypeSelect = document.getElementById('event-type-select');
        const customEventType = document.getElementById('custom-event-type').value;

        designData.eventType = customEventType || eventTypeSelect.value;
        
        if (designData.eventType) {
            navigateTo('dimensions');
        } else {
            alert('Please select or specify an event type.');
        }
    });

    // --- Page 2: Dimensions & Extras Logic ---
    dimensionsForm.addEventListener('submit', (e) => {
        e.preventDefault();
        designData.dimensions = {
            hallArea: document.getElementById('hall-area').value,
            stageLength: document.getElementById('stage-length').value,
            stageWidth: document.getElementById('stage-width').value,
            stageHeight: document.getElementById('stage-height').value,
        };
        
        const selectedExtras = Array.from(document.querySelectorAll('input[name="extra"]:checked')).map(el => el.value);
        const otherExtras = document.getElementById('other-extras').value.split(',').map(s => s.trim()).filter(Boolean);
        designData.extras = [...selectedExtras, ...otherExtras];
        
        navigateTo('style');
    });

    // --- Page 3: Style Logic ---
    styleForm.addEventListener('submit', (e) => {
        e.preventDefault();
        designData.styles = Array.from(document.querySelectorAll('input[name="style"]:checked')).map(el => el.value);
        
        if (designData.styles.length > 0) {
            navigateTo('visualization');
            generateImage();
        } else {
            alert('Please select at least one design style.');
        }
    });
    
   async function generateImage() {
    loadingSpinner.classList.remove('hidden');
    errorContainer.classList.add('hidden');
    generatedImage.classList.add('hidden');
    ctaFooter.classList.add('hidden');

    const prompt =
      `A ${designData.styles.join(', ')} style ${designData.eventType} venue. ` +
      `Hall ${designData.dimensions.hallArea} m², stage ${designData.dimensions.stageLength}×` +
      `${designData.dimensions.stageWidth}×${designData.dimensions.stageHeight} m. ` +
      `Includes ${designData.extras.join(', ')}. Photorealistic, cinematic, 8k.`;

    try {
        const res = await fetch("http://localhost:8000/generate", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ prompt })
        });
        if (!res.ok) throw new Error(await res.text());
        const { image } = await res.json();               // base64 PNG string
        generatedImage.src = `data:image/png;base64,${image}`;
        generatedImage.onload = () => {
            loadingSpinner.classList.add('hidden');
            generatedImage.classList.remove('hidden');
            ctaFooter.classList.remove('hidden');
        };
    } catch (err) {
        console.error(err);
        loadingSpinner.classList.add('hidden');
        errorContainer.classList.remove('hidden');
    }
}
});