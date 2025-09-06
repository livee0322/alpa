import React from 'react';

interface FormSectionContainerProps {
    title: string;
    children: React.ReactNode;
}

export default function FormSectionContainer({ title, children }: FormSectionContainerProps) {
    return (
        <div className="mb-4 p-4 bg-white border border-gray-200 rounded-xl shadow-sm">
            <h2 className="text-lg font-bold mb-3">{title}</h2>
            {children}
        </div>
    );
}