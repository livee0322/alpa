'use client';
import { usePortfolioFormStore } from '@/lib/stores/portfolioFormStore';

export default function PortfolioExperienceSection() {
    const { experienceYears, age, setFormData } = usePortfolioFormStore();
    const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const { name, value } = e.target;
        setFormData({ [name]: parseInt(value) || null });
    };

    return (
        <div className="flex space-x-4">
            <input
                type="number"
                name="experienceYears"
                placeholder="경력(년)"
                value={experienceYears || ''}
                onChange={handleChange}
                className="flex-1 px-4 py-3 border border-gray-300 rounded-lg"
            />
            <input
                type="number"
                name="age"
                placeholder="나이"
                value={age || ''}
                onChange={handleChange}
                className="flex-1 px-4 py-3 border border-gray-300 rounded-lg"
            />
        </div>
    );
}