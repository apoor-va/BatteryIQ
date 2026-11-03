/**
 * BatteryIQ - Automotive Marketplace Interactive JavaScript
 * Handles multi-category search, dynamic condition tabs, inventory filters,
 * comparison switcher, and live valuation calculators.
 */

document.addEventListener('DOMContentLoaded', () => {
    initHomeSearchTabs();
    initInventoryFilterTabs();
    initFilterRadioPills();
    initLegacySupport();
});

/**
 * Handle Condition tabs in Hero Search Box (All Vehicles, Brand New, Certified Used)
 */
function initHomeSearchTabs() {
    const tabs = document.querySelectorAll('.search-box-tabs .s-tab');
    const conditionInput = document.getElementById('hidden-condition');

    tabs.forEach(tab => {
        tab.addEventListener('click', (e) => {
            tabs.forEach(t => t.classList.remove('active'));
            e.currentTarget.classList.add('active');

            const condition = e.currentTarget.getAttribute('data-condition');
            if (conditionInput) {
                conditionInput.value = condition;
            }
        });
    });
}

/**
 * Handle Category Filter Tabs in Homepage Featured Inventory
 */
function initInventoryFilterTabs() {
    const tabs = document.querySelectorAll('.inventory-tabs .inv-tab');
    const cards = document.querySelectorAll('.vehicle-cards-grid .vehicle-card');

    if (!tabs.length || !cards.length) return;

    tabs.forEach(tab => {
        tab.addEventListener('click', (e) => {
            tabs.forEach(t => t.classList.remove('active'));
            e.currentTarget.classList.add('active');

            const filter = e.currentTarget.getAttribute('data-filter');

            cards.forEach(card => {
                const category = card.getAttribute('data-category') || '';
                const fuel = card.getAttribute('data-fuel') || '';

                if (filter === 'all') {
                    card.style.display = 'flex';
                } else if (filter === 'ELECTRIC') {
                    card.style.display = (fuel.toUpperCase() === 'ELECTRIC') ? 'flex' : 'none';
                } else {
                    card.style.display = (category.toUpperCase() === filter.toUpperCase()) ? 'flex' : 'none';
                }
            });
        });
    });
}

/**
 * Radio Pill buttons inside sidebar filters
 */
function initFilterRadioPills() {
    const pills = document.querySelectorAll('.filter-radio-pills .radio-pill');
    pills.forEach(pill => {
        pill.addEventListener('click', () => {
            const container = pill.closest('.filter-radio-pills');
            if (container) {
                container.querySelectorAll('.radio-pill').forEach(p => p.classList.remove('active'));
                pill.classList.add('active');
            }
        });
    });
}

/**
 * Legacy support for any existing handlers
 */
function initLegacySupport() {
    // Newsletter subscription form
    const form = document.querySelector('.newsletter-form');
    if (form) {
        form.addEventListener('submit', (e) => {
            e.preventDefault();
            const input = form.querySelector('.newsletter-input');
            if (input && input.value) {
                alert(`Thank you for subscribing to BatteryIQ Market Intelligence! Updates will be sent to ${input.value}.`);
                input.value = '';
            }
        });
    }
}
